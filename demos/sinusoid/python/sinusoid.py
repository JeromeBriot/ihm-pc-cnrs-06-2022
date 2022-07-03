import sys
import time
import platform

from math import nan

import threading
import queue

import serial
import serial.tools.list_ports

import tkinter as tk
from tkinter import ttk

if platform.system() == 'Windows':      # Windows - COM*
    serialPort = 'COM6'
elif platform.system() == 'Darwin':     # macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem22101'
else:                                   # Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0'

if not serialPort in [x.device for x in list(serial.tools.list_ports.comports())]:
    print('Error: Serial port {} not available.'.format(serialPort))
    sys.exit()

ser = serial.Serial(port=None, baudrate=9600)

isSerialConnected = False

stopThread = False

queueCom = queue.Queue()

threadCom = None

incomingMsg = ''

nCoords = 260*2

data = [nan]*(nCoords-10*2)

data[0::2] = list(range(10,nCoords//2))

def read_from_port():

    global incomingMsg

    while True:

        if stopThread:
            break

        if isSerialConnected:

            n = ser.in_waiting

            if n > 0:

                reading = ser.read(1)

                incomingMsg += reading.decode('utf-8')

                if incomingMsg[-1] == '\n':
                    queueCom.put(incomingMsg)
                    incomingMsg = ''

        else:
            time.sleep(0.01)


threadCom = threading.Thread(target=read_from_port)


def connection():

    global isSerialConnected

    if isSerialConnected:

        isSerialConnected = False
        ser.close()
        textVar.set('Connect')
        comboboxSet.config(state=tk.DISABLED)
        comboboxSet.current(0)

    else:

        ser.port = serialPort
        ser.open()
        root.config(cursor='watch')
        time.sleep(3) # Chargement du bootloader par l'Arduino
        root.config(cursor='')
        isSerialConnected = True
        textVar.set('Disconnect')
        comboboxSet.config(state=tk.NORMAL)

        if not threadCom.is_alive():
            threadCom.start()

        ser.reset_input_buffer()


def setFrequency(*args):

    idx = comboboxSet.current() + 1

    ser.write(bytes(str(idx), 'utf8'))


def quit():

    global stopThread
    global isConnected

    if isSerialConnected:
        isConnected = False
        ser.close()

    if threadCom.is_alive():
        stopThread = True
        threadCom.join()

    root.quit()


def periodicCall():

    if isSerialConnected:

        while queueCom.qsize():

            msg = queueCom.get(0).rstrip()
            if msg:
                val = int(msg)

                data[1:-1:2] = data[3::2]
                data[-1] = int((154 - 5) - (val + 128) / 256 * (154 - 5) + 5)

                update_graph()

    root.after(5, periodicCall)


def update_graph():

    canvas.delete('graph')
    canvas.create_line(*data, width=3, fill='blue', tags='graph')


root = tk.Tk()

root.geometry('400x200')

buttonQuit = tk.Button(root, text='Quit', command=quit)
buttonQuit.place(x=20, y=140, width=80, height=40)

comboboxSet = ttk.Combobox(root, values=['0.1 Hz', '0.2 Hz', '0.5 Hz', '1 Hz'], state=tk.DISABLED)
comboboxSet.place(x=20, y=80, width=80, height=40)
comboboxSet.current(0)
comboboxSet.bind('<<ComboboxSelected>>', setFrequency)

textVar = tk.StringVar(master=root, value='Connect')
buttonConnection = tk.Button(root, textvariable=textVar , command=connection)
buttonConnection.place(x=20, y=20, width=80, height=40)

canvas = tk.Canvas(root)
canvas.place(x=120, y=20, width=260, height=160)
canvas.create_rectangle(10,1,258,158, fill='white', outline='black')
canvas.create_line(10, 79, 259, 79, width=1, arrow='last')
canvas.create_line(10, 0, 10, 159, width=1, arrow='first')

graph = canvas.create_line(*data, width=2, fill='blue', tags='graph')

root.after(5, periodicCall)

root.mainloop()
