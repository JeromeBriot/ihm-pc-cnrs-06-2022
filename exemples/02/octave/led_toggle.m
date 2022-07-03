function led_toggle

  pkg load instrument-control

  if ispc         % Windows - COM*
    serialPort = 'COM7';
  elseif ismac    % macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem21101';
  else            % Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyUSB*';
  end

  freeports = serialportlist("available");
  if ~any(ismember(freeports, serialPort))
    error('Serial port %s not available.', serialPort)
  end

  ser = serialport(serialPort, 9600);

  pause(3); % Chargement du bootloader par l'Arduino

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
    write(ser, '1');
  endfunction

  function turnLedOff(obj, event)
    write(ser, '0');
  endfunction

  function quitApp(obj, event)
    clear ser
    close(gcbf)
  endfunction

endfunction

