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

time.sleep(3) # Chargement du bootloader par l'Arduino

isLedOn = False

def toggleLedState():

    global isLedOn

    if isLedOn:
        ser.write(b'0')
        isLedOn = False
        buttonLedState.config(text='LED On')
    else:
        ser.write(b'1')
        isLedOn = True
        buttonLedState.config(text='LED Off')

def quitApp():

    ser.close()
    root.quit()

def resizeButtonText(event):

    textSize = event.width // 10

    if textSize < 10:
        textSize = 10

    buttonLedState.config(font=('TkDefaultFont', textSize) )
    buttonQuit.config(font=('TkDefaultFont', textSize) )

    pass

root = tk.Tk()

root.geometry('200x140')

buttonQuit = tk.Button(root, text='Quit', command=quitApp)
buttonQuit.place(relx=0.3, rely=0.5714, relwidth=0.4, relheight=0.2857)

buttonLedState = tk.Button(root, text='LED On', command=toggleLedState)
buttonLedState.place(relx=0.3, rely=0.1429, relwidth=0.4, relheight=0.2857)

root.bind('<Configure>', resizeButtonText)

root.mainloop()
