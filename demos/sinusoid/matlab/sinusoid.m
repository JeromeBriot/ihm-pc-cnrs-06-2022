function sinusoid

if ispc         % Windows - COM*
    serialPort = 'COM9';
elseif ismac	% macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem21101';
else            % Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0';
end

freeports = serialportlist("available");
if ~any(contains(freeports, serialPort))
    error('Serial port %s not available.', serialPort)
end

ser = [];

isSerialConnected = false;

quitFunction = false;

data = NaN(1, 400);

h_figure = figure('units', 'pixels', ...
    'position', [0 0 400 200], ...
    'menubar', 'none', ...
    'toolbar', 'none', ...
    'renderer', 'painter');

uicontrol(h_figure, ...
    'style', 'pushbutton', ...
    'units', 'pixels', ...
    'position', [20 20 80 40], ...
    'string', 'Quit', ...
    'callback', @quit)

h_popup = uicontrol(h_figure, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [20 80 80 40], ...
    'string', {'0.1 Hz', '0.2 Hz', '0.5 Hz', '1 Hz'}, ...
    'value', 1, ...
    'callback', @setFrequency, ...
    'enable', 'off');

uicontrol(h_figure, ...
    'style', 'pushbutton', ...
    'units', 'pixels', ...
    'position', [20 140 80 40], ...
    'string', 'Connect', ...
    'callback', @connection)

h_axes = axes('units', 'pixels', ...
    'position', [140 20 240 160], ...
    'box', 'on', ...
    'xlim', [0 400], ...
    'ylim', [-128 128], ...
    'xtick', [], ...
    'nextplot', 'add');

h_plot = plot(h_axes, data);

    function connection(obj, event)
        
        if isSerialConnected
            
            isSerialConnected = false;
            delete(ser);
            set(obj, 'string', 'Connect');
            set(h_popup, 'enable', 'off');
            
        else
            
            isSerialConnected = true;
            ser = serialport(serialPort, 9600);
            set(gcbf, 'pointer', 'watch')
            pause(3) % Chargement du bootloader par l'Arduino
            set(gcbf, 'pointer', 'arrow')
            set(obj, 'string', 'Disconnect');
            set(h_popup, 'enable', 'on');
            
        end
        
    end

    function readSerialData
        
        if isSerialConnected && ser.NumBytesAvailable
            
            str = readline(ser);

            tmp = str2double(str);
            
            if isnumeric(tmp)
                
                data(1:end-1) = data(2:end);
                data(end) = tmp;
                
                set(h_plot, 'ydata', data);
                
            end
            
        end
        
    end

    function setFrequency(obj, event)
        
        value = get(obj, 'value');
        
        write(ser, sprintf('%d', value), 'char');
        
    end

    function quit(obj, event)
        
        if isSerialConnected
            delete(ser)
        end
        
        close(gcbf)
        quitFunction = true;
        
    end

while 1
    
    drawnow;
    
    if quitFunction
        break;
    end
    
    readSerialData
    
end

end