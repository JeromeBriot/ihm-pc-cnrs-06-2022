% Port s�rie sur lequel l'Arduino est branch�
if ispc         % Windows - COM*
    serialPort = 'COM7';
elseif ismac	% macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem21101';
else            % Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyACM0';
end

% Test de disponibilit� du port s�rie
freeports = serialportlist("available");
if ~any(contains(freeports, serialPort))
    error('Serial port %s not available.', serialPort)
end

% Cr�ation de l'objet s�rie et ouverture du port
ser = serialport(serialPort, 9600);

% Pause de 3 secondes suite au reset de l'Arduino et chargement de son bootloader
pause(3) 

% Envoi d'un caract�re sur le port s�rie
write(ser, '1', 'char');

% Fermeture du port et suppression de l'objet s�rie
delete(ser);