import sys
import time
import platform

import serial
import serial.tools.list_ports

# Port série sur lequel l'Arduino est branché
if platform.system() == 'Windows':      # Windows - COM*
    serialPort = 'COM7'
elif platform.system() == 'Darwin':     # macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem22101'
else:                                   # Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0'

# Test de disponibilité du port série
if not serialPort in [x.device for x in list(serial.tools.list_ports.comports())]:
    print('Error: Serial port {} not available.'.format(serialPort))
    sys.exit()

# Création de l'objet série et ouverture du port
ser = serial.Serial(port=serialPort, baudrate=9600)

# Pause de 3 secondes suite au reset de l'Arduino et chargement de son bootloader
time.sleep(3)

# Envoi d'un caractère sur le port série
ser.write(b'1')

# Fermeture du port et suppression de l'objet série
ser.close()
