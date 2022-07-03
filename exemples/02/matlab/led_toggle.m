function led_toggle

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

pause(3) % Bootloader Arduino

figure('units', 'pixels', ...
    'position', [0 0 200 200], ...
    'menubar', 'none', ...
    'toolbar', 'none')

uicontrol('style', 'pushbutton', ...
    'units', 'pixels', ...
    'position', [60 20 80 40], ...
    'string', 'Quit', ...
    'callback', @quitApp)

uicontrol('style', 'pushbutton', ...
    'units', 'pixels', ...
    'position', [60 80 80 40], ...
    'string', 'LED Off', ...
    'callback', @turnLedOff)

uicontrol('style', 'pushbutton', ...
    'units', 'pixels', ...
    'position', [60 140 80 40], ...
    'string', 'LED On', ...
    'callback', @turnLedOn)

    function turnLedOn(obj, event)
        write(ser, '1', 'char');
    end

    function turnLedOff(obj, event)
        write(ser, '0', 'char');
    end

    function quitApp(obj, event)
        delete(ser)
        close(gcbf)
    end

end