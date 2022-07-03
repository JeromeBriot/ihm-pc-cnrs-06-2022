import sys
import time
import platform

import serial
import serial.tools.list_ports

import tkinter as tk

if platform.system() == 'Windows':      # Windows - COM*
    serialPort = 'COM7'
elif platform.system() == 'Darwin':     # macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem22101'
else:                                   # Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0'

if not serialPort in [x.device for x in list(serial.tools.list_ports.comports())]:
    print('Error: Serial port {} not available.'.format(serialPort))
    sys.exit()

ser = serial.Serial(port=serialPort, baudrate=9600)

time.sleep(3) # Bootloader Arduino

def turnLedOn():

    ser.write(b'1')

def turnLedOff():

    ser.write(b'0')

def quitApp():

    ser.close()
    root.quit()

root = tk.Tk()

root.geometry('200x200')

buttonQuit = tk.Button(root, text='Quit',
                       command=quitApp)
buttonQuit.place(x=60, y=140,
                 width=80, height=40)

buttonOff = tk.Button(root, text='LED Off',
                      command=turnLedOff)
buttonOff.place(x=60, y=80,
                width=80, height=40)

buttonOn = tk.Button(root, text='LED On',
                     command=turnLedOn)
buttonOn.place(x=60, y=20,
               width=80, height=40)

root.mainloop()


