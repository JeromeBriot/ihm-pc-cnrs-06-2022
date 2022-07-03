if getos() == 'Windows' then    // Windows - COM*
    serialPort = 'COM7'
elseif getos() == 'Darwin' then // macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    error('Serial Communication Toolbox not supported on macOS')
else                            // Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0'
end

ser = openserial(serialPort, '9600,n,8,1')

sleep(3, 's') // Chargement du bootloader par l'Arduino

writeserial(ser, '1')

closeserial(ser)
