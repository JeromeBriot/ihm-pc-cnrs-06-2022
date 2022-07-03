% Port série sur lequel l'Arduino est branché
if ispc         % Windows - COM*
    serialPort = 'COM7';
elseif ismac	% macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem21101';
else            % Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0';
end

% Test de disponibilité du port série
freeports = serialportlist("available");
if ~any(contains(freeports, serialPort))
    error('Serial port %s not available.', serialPort)
end

% Création de l'objet série et ouverture du port
ser = serialport(serialPort, 9600);

% Pause de 3 secondes suite au reset de l'Arduino et chargement de son bootloader
pause(3) 

% Envoi d'un caractère sur le port série
write(ser, '1', 'char');

% Fermeture du port et suppression de l'objet série
delete(ser);