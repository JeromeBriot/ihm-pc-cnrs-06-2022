if ispc         % Windows - COM*
    serialPort = 'COM7';
elseif ismac	% macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem21101';
else            % Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0';
end

freeports = serialportlist("available");
if ~any(contains(freeports, serialPort))
    error('Serial port %s not available.', serialPort)
end

ser = serialport(serialPort, 9600);

pause(3) % Chargement du bootloader par l'Arduino

while 1
    
    inChar = input('Press a key (1: on ; 0: off ; q: quit): ', 's');
    
    if inChar == 'q'
        break;
    elseif inChar == '0' || inChar == '1'
        write(ser, inChar, 'char');
    end
    
end

delete(ser);