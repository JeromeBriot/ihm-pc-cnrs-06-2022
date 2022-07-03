function tftpaint

  pkg load instrument-control

  if ispc         % Windows - COM*
    serialPort = 'COM5';
  elseif ismac    % macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem21101';
  else            % Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyUSB*';
  end

  freeports = serialportlist("available");
  if ~any(ismember(freeports, serialPort))
    error('Serial port %s not available.', serialPort)
  end

  quitFunction = false;

  colors888 = [0.9725 0 0
               0.9725 0.9882 0
               0 0.9882 0
               0 0.9882 0.9725
               0 0 0.9725
               0.9725 0 0.9725];

  currentColorIndex = 1;

  str = [''];

  h_figure = figure('units', 'pixels', ...
  'position', [0 0 320 240], ...
  'menubar', 'none', ...
  'toolbar', 'none', ...    'renderer', 'painter', ...
  'closerequestfcn', @quit);

  axes('units', 'pixels', ...
  'position', [0 0 320 240], ...
  'color', 'black', ...
  'box', 'off', ...
  'xlim', [0 320], ...
  'ylim', [0 240], ...
  'xtick', [], ...
  'ytick', [], ...
  'xcolor', 'white', ...
  'ycolor', 'white', ...
  'xlimmode', 'manual', ...
  'ylimmode', 'manual', ...
  'nextplot', 'add', ...
  'DataAspectRatio', [1 1 1], ...
  'PlotBoxAspectRatio', [3 4 4]);

  line([1 40 40 1 ; 40 40 1 1], [1 1 240 240 ; 1 240 240 1], zeros(2,4), 'color', 'white', 'linewidth', 2)

  for i = 1:6
    rectangle('position', [40 (i-1)*40 39 39], 'facecolor', colors888(i,:), 'edgecolor', colors888(i,:))
  endfor

  ser = serialport(serialPort, 9600);
  configureTerminator (ser, 'CR/LF', 'CR/LF')
  flush(ser)
  set(h_figure, 'pointer', 'watch')
  pause(3) % Chargement du bootloader par l'Arduino
  set(h_figure, 'pointer', 'arrow')

  function readSerialData

    n = get(ser, 'NumBytesAvailable');

    if n > 0

      tmp = fread(ser, 1, 'uchar');

      if tmp == 10

        if str(1) == 'X'
          xy = sscanf(str, 'X%dY%d');
          drawPoint(xy(2), xy(1), colors888(currentColorIndex,:));
        elseif str(1) == '!'
          h = findobj('tag', 'point');
          delete(h)
        elseif str(1) == 'R'
          currentColorIndex = 1;
        elseif str(1) == 'Y'
          currentColorIndex = 2;
        elseif str(1) == 'G'
          currentColorIndex = 3;
        elseif str(1) == 'C'
          currentColorIndex = 4;
        elseif str(1) == 'B'
          currentColorIndex = 5;
        elseif str(1) == 'M'
          currentColorIndex = 6;
        end

        str = [''];

      elseif tmp ~= 13

        str = [str char(tmp)];

      endif

    endif

  endfunction

  function quit(~, ~)

    clear ser

    delete(gcf)
    quitFunction = true;

  endfunction

  function drawPoint(x, y, color)
    plot(x, y, ...
    'color', color, ...
    'marker', 'o', ...
    'markerfacecolor', color, ...
    'linestyle', 'none', ...
    'markersize', 4, ...
    'tag', 'point')
  endfunction

  while 1

    drawnow;

    if quitFunction
      break;
    endif

    readSerialData

  endwhile

  endfunction
