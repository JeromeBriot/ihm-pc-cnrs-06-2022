if getos() == 'Windows' then    // Windows - COM*
    serialPort = 'COM7'
elseif getos() == 'Darwin' then // macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    error('Serial Communication Toolbox not supported on macOS')
else                            // Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0'
end

ser = openserial(serialPort, '9600,n,8,1')

sleep(3, 's') // Chargement du bootloader par l'Arduino

while 1

  inChar = input('Press a key (1: on ; 0: off ; q: quit): ', 'string');

  if inChar == 'q' then
    break
  elseif inChar == '0' || inChar == '1' then
    writeserial(ser, inChar)
  end

end

closeserial(ser)
