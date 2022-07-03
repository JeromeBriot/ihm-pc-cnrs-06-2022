import sys
import time
import platform

import serial
import serial.tools.list_ports

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

while 1:

    inChar = input('Press a key (1: on ; 0: off ; q: quit): ')

    if inChar == 'q':
        break

    elif inChar == '0' or inChar == '1':
        ser.write(inChar.encode())

ser.close()
