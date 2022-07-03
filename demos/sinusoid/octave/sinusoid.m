function sinusoid

  pkg load instrument-control

  if ispc         % Windows - COM*
    serialPort = 'COM6';
  elseif ismac    % macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem21101';
  else            % Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyUSB*';
  end

  freeports = serialportlist("available");
  if ~any(ismember(freeports, serialPort))
    error('Serial port %s not available.', serialPort)
  end

  isSerialConnected = false;

  quitFunction = false;

  ser = [];

  str = [''];

  data = NaN(1, 400);

  figure('units', 'pixels', ...
  'position', [0 0 400 200], ...
  'menubar', 'none', ...
  'toolbar', 'none')

  uicontrol('style', 'pushbutton', ...
  'units', 'pixels', ...
  'position', [20 20 80 40], ...
  'string', 'Quit', ...
  'callback', @quit)

  h_popup = uicontrol('style', 'popupmenu', ...
  'units', 'pixels', ...
  'position', [20 80 80 40], ...
  'string', {'0.1 Hz', '0.2 Hz', '0.5 Hz', '1 Hz'}, ...
  'value', 1, ...
  'callback', @setFrequency, ...
  'enable', 'off');

  uicontrol('style', 'pushbutton', ...
  'units', 'pixels', ...
  'position', [20 140 80 40], ...
  'string', 'Connect', ...
  'callback', @connection)

  ax = axes('units', 'pixels', ...
  'position', [140 20 240 160], ...
  'box', 'on', ...
  'xlim', [0 400], ...
  'ylim', [-128 128], ...
  'xtick', [], ...
  'nextplot', 'add');

  p = plot(ax, data);

  function connection(obj, event)

    if isSerialConnected

      isSerialConnected = false;
      clear ser
      set(obj, 'string', 'Connect');
      set(h_popup, 'enable', 'off');

    else

      isSerialConnected = true;
      ser = serialport(serialPort, 9600);
      configureTerminator (ser, 'CR/LF', 'CR/LF')
      flush(ser)
      set(gcbf, 'pointer', 'watch')
      pause(3) % Chargement du bootloader par l'Arduino
      set(gcbf, 'pointer', 'arrow')
      set(obj, 'string', 'Disconnect');
      set(h_popup, 'enable', 'on');

    endif

  endfunction

  function readSerialData

    if isSerialConnected

      n = get(ser, 'NumBytesAvailable');

      if n > 0

        tmp = fread(ser, 1, 'uchar');

        if tmp == 10

          data(1:end-1) = data(2:end);
          data(end) = str2double(str);

          set(p, 'ydata', data);

          str = [''];

        elseif tmp ~= 13

          str = [str char(tmp)];

        endif

      endif

    endif

  endfunction

  function setFrequency(obj, event)

    value = get(obj, 'value');

    fprintf(ser, sprintf('%d', value));

  endfunction

  function quit(obj, event)

    if isSerialConnected
      clear ser
    endif

    close(gcbf)
    quitFunction = true;

  endfunction

  while 1

    drawnow;

    if quitFunction
      break;
    endif

    readSerialData

  endwhile

  endfunction
