global ser
global str
global quitFunction
global isSerialConnected

if getos() == 'Windows' then    // Windows - COM*
    serialPort = 'COM6'
elseif getos() == 'Darwin' then // macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    error('Serial Communication Toolbox not supported on macOS')
else                            // Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0'
    usecanvas(%T)
end

str = ''
quitFunction = %F
isSerialConnected = %F

dummyData = ones(400,1)*%nan

figure('position', [0, 0, 400, 200], ...
'menubar_visible', 'off', ...
'toolbar_visible', 'off', ...
'infobar_visible', 'off')

uicontrol('style', 'pushbutton', ...
'units', 'pixels', ...
'position', [20 20 80 40], ...
'string', 'Quit', ...
'callback', 'quitt', ...
'callback_type', 12)

h_popup = uicontrol('style', 'popupmenu', ...
'units', 'pixels', ...
'position', [20 80 80 40], ...
'string', ['0.1 Hz', '0.2 Hz', '0.5 Hz', '1 Hz'], ...
'value', 1, ...
'callback', 'setFrequency', ...
'enable', 'off', ...
'callback_type', 12);

h_button = uicontrol('style', 'pushbutton', ...
'units', 'pixels', ...
'position', [20 140 80 40], ...
'string', 'Connect', ...
'callback', 'connection', ...
'callback_type', 12)

ax = gca()
ax.axes_bounds = [1/3,0,2/3,1]
ax.data_bounds = [0,10,-128,128]
h_point = plot(ax, dummyData)

function connection()

    global ser
    global isSerialConnected    

    if isSerialConnected then
        isSerialConnected = %F
        closeserial(ser)
        set(h_button, 'string', 'Connect')
        set(h_popup, 'enable', 'off')
    else
        isSerialConnected = %T
        ser = openserial(serialPort, '9600,n,8,1')
        sleep(3, 's') // Chargement du bootloader par l'Arduino
        set(h_button, 'string', 'Disconnect')
        set(h_popup, 'enable', 'on')
    end

endfunction

function readSerialData

    global str
     
    if isSerialConnected then

        tmp = readserial(ser, 1)

        if tmp == ascii(10)

            data = get(h_point, 'data')

            data(1:$-1,2) = data(2:$,2)
            data($,2) = strtod(str)

            set(h_point, 'data', data)

            str = ''

        elseif tmp ~= ascii(13)

            str = str + char(tmp)

        end

    end

endfunction

function setFrequency()

    value = get(h_popup, 'value')

    writeserial(ser, msprintf('%d', value))

endfunction

function quitt()

    global quitFunction

    if isSerialConnected then
        isSerialConnected = %F
        closeserial(ser)
    end
    
    quitFunction = %T
    
    delete(gcf())   

endfunction

while 1
         
    if quitFunction then
        break
    end
    
    readSerialData

end
