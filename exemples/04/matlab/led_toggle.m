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

pause(3) % Chargement du bootloader par l'Arduino

isLedOn = false;

figure('units', 'pixels', ...
    'position', [0 0 200 140], ...
    'menubar', 'none', ...
    'toolbar', 'none')

uicontrol('style', 'pushbutton', ...
    'units', 'normalized', ...
    'position', [0.3 0.1429 0.4 0.2857], ...
    'fontunits', 'normalized', ...
    'string', 'Quit', ...
    'callback', @quitApp)

h_button = uicontrol('style', 'pushbutton', ...
    'units', 'normalized', ...
    'position', [0.3 0.5714 0.4 0.2857], ...
    'fontunits', 'normalized', ...
    'string', 'LED On', ...
    'callback', @toggleLedState);

    function toggleLedState(obj, event) 
        
        if isLedOn
            write(ser, '0', 'char');
            isLedOn = false;
            set(h_button, 'string', 'LED On')
        else
            write(ser, '1', 'char');
            isLedOn = true;
            set(h_button, 'string', 'LED Off')
        end
                
    end

    function quitApp(obj, event)        
        delete(ser)        
        close(gcbf)
    end

end