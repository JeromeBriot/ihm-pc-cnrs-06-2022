if getos() == 'Windows' then    // Windows - COM*
    serialPort = 'COM7'
elseif getos() == 'Darwin' then // macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    error('Serial Communication Toolbox not supported on macOS')
else                            // Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0'
    usecanvas(%T)
end

ser = openserial(serialPort, '9600,n,8,1')

sleep(3, 's') // Chargement du bootloader par l'Arduino

isLedOn = %F;

figure('position', [0, 0, 200, 140], ...
'menubar_visible', 'off', ...
'toolbar_visible', 'off', ...
'infobar_visible', 'off')

uicontrol('style', 'pushbutton', ...
'units', 'pixels', ...
'position', [60 20 80 40], ...
'string', 'Quit', ...
'callback', 'quitApp')

h_button = uicontrol('style', 'pushbutton', ...
'units', 'pixels', ...
'position', [60 80 80 40], ...
'string', 'LED On', ...
'callback', 'toggleLedState')

function toggleLedState()
    
    global isLedOn
    
    if isLedOn
        writeserial(ser, '0')
        isLedOn = %F;
        set(h_button, 'string', 'LED On')
    else
        writeserial(ser, '1')
        isLedOn = %T;
        set(h_button, 'string', 'LED Off')
    end
    
endfunction

function quitApp()
    closeserial(ser)
    close()
endfunction
