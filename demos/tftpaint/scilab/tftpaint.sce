global quitFunction
global currentColorIndex

if getos() == 'Windows' then    // Windows - COM*
    serialPort = 'COM5'
elseif getos() == 'Darwin' then // macOS - /dev/tty.usbmodem* or /dev/tty.usbserial*
    error('Serial Communication Toolbox not supported on macOS')
else                            // Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0'
    usecanvas(%T)
end

currentColorIndex = 1;

quitFunction = %F

colors888 = [0.9725 0 0
0.9725 0.9882 0
0 0.9882 0
0 0.9882 0.9725
0 0 0.9725
0.9725 0 0.9725]*255;

h_figure = figure('position', [0, 0, 320, 240], ...
'menubar_visible', 'off', ...
'toolbar_visible', 'off', ...
'infobar_visible', 'off', ...
'closerequestfcn', 'quitt')

ax = newaxes(h_figure)
ax.margins = [0,0,0,0]
ax.axes_bounds = [0, 0, 1, 1]
ax.data_bounds = [0, 320, 0, 240]
ax.background = color('black')

plot(ax, [1 40 40 1 ; 40 40 1 1], [1 1 240 240 ; 1 240 240 1], 'color', ['white','white','white','white'])

for i = 1:6
    xfrect(40, i*40, 39, 39)
    gce().background = color(colors888(i,1), colors888(i,2), colors888(i,3));
end

ser = openserial(serialPort, '9600,n,8,1')
sleep(3, 's') // Chargement du bootloader par l'Arduino

function readSerialData

    global str
    global currentColorIndex

    tmp = readserial(ser, 1)

    if tmp == ascii(10) then
        
        if part(str,1) == 'X' then
            [n,x,y] = msscanf(str, 'X%dY%d')
            drawPoint(y, x, color(colors888(currentColorIndex,1), colors888(currentColorIndex,2), colors888(currentColorIndex,3)))
        elseif part(str,1) == '!' then
            h = findobj('tag', 'point')
            delete(h)
        elseif part(str,1) == 'R' then
            currentColorIndex = 1
        elseif part(str,1) == 'Y' then
            currentColorIndex = 2
        elseif part(str,1) == 'G' then
            currentColorIndex = 3
        elseif part(str,1) == 'C' then
            currentColorIndex = 4
        elseif part(str,1) == 'B' then
            currentColorIndex = 5
        elseif part(str,1) == 'M' then
            currentColorIndex = 6
        end

        str = ''

    elseif tmp ~= ascii(13) then

        str = str + char(tmp)

    end

endfunction

function drawPoint(x, y, c)
    drawlater()
    p = plot(x, y,'o')
    p.mark_background = c
    p.mark_foreground = c
    p.tag = 'point'
    drawnow()
endfunction

function quitt

    global quitFunction

    closeserial(ser)

    quitFunction = %T 

    delete(gcf())

endfunction

while 1

    if quitFunction then
        break
    end

    readSerialData

end
