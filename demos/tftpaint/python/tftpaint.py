import sys
import time
import platform

import threading
import queue

import serial
import serial.tools.list_ports

import tkinter as tk

if platform.system() == 'Windows':      # Windows - COM*
    serialPort = 'COM5'
elif platform.system() == 'Darwin':     # macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem22101'
else:                                   # Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0'

if not serialPort in [x.device for x in list(serial.tools.list_ports.comports())]:
    print('Error: Serial port {} not available.'.format(serialPort))
    sys.exit()

colors888 = ['#F800F8', '#0000F8', '#00FCF8', '#00FC00', '#F8FC00', '#F80000']

currentColorIndex = 5

stopThread = False

queueCom = queue.Queue()

threadCom = None

incomingMsg = ''

def read_from_port():

    global incomingMsg

    while True:

        if stopThread:
            break

        n = ser.in_waiting

        if n > 0:

            reading = ser.read(1)

            incomingMsg += reading.decode('utf-8')

            if incomingMsg[-1] == '\n':
                queueCom.put(incomingMsg)
                incomingMsg = ''

        else:
            time.sleep(0.01)


def periodicCall():

    global currentColorIndex

    while queueCom.qsize():

        msg = queueCom.get(0).rstrip()

        if msg:

            if msg[0]== 'X':
                xy = [int(x) for x in msg.split('X')[1].split('Y')]
                drawPoint(xy[1], xy[0], colors888[currentColorIndex])
            elif msg[0]== '!':
                canvas.delete('point')
            elif msg[0]== 'R':
                currentColorIndex = 5
            elif msg[0]== 'Y':
                currentColorIndex = 4
            elif msg[0]== 'G':
                currentColorIndex = 3
            elif msg[0]== 'C':
                currentColorIndex = 2
            elif msg[0]== 'B':
                currentColorIndex = 1
            elif msg[0]== 'M':
                currentColorIndex = 0

    root.after(5, periodicCall)


def drawPoint(x, y, c):

    r = 3
    y = 240-y
    canvas.create_oval(x-r, y-r, x+r, y+r, fill=c, outline=c, tag='point')
    pass


def quit():

    global stopThread

    ser.close()
    root.quit()

    if threadCom.is_alive():
        stopThread = True
        threadCom.join()


root = tk.Tk()

root.geometry('320x240')

canvas = tk.Canvas(root, background='black')
canvas.place(x=0, y=0, width=320, height=240)

canvas.create_rectangle(0, 0, 40, 240, outline='white')

for i in range(0,6):
    canvas.create_rectangle(41, i*40, 2*40, (i+1)*40, fill=colors888[i], outline=colors888[i])

root.protocol("WM_DELETE_WINDOW", quit)

ser = serial.Serial(port=serialPort, baudrate=9600)
time.sleep(3) # Chargement du bootloader par l'Arduino

threadCom = threading.Thread(target=read_from_port)
threadCom.start()

root.after(5, periodicCall)

root.mainloop()