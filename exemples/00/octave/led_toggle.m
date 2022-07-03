% Chargement du package Instrument-Control
pkg load instrument-control

% Port serie sur lequel l'Arduino est branche
if ispc         % Windows - COM*
    serialPort = 'COM7';
elseif ismac    % macOS - /dev/tty.usbmodem* ou /dev/tty.usbserial*
    serialPort = '/dev/tty.usbmodem21101';
else            % Linux - /dev/ttyUSB* ou /dev/ttyACM*
    serialPort = '/dev/ttyUSB*';
end

% Recherche de la disponibilite du port serie
freeports = serialportlist("available");
if ~any(ismember(freeports, serialPort))
    error('Serial port %s not available.', serialPort)
end

% Creation de l'objet serie et ouverture du port
ser = serialport(serialPort, 9600);

% Pause de 3 secondes suite au reset de l'Arduino et chargement de son bootloader
pause(3);

% Envoi d'un caractere sur le port serie
write(ser, '1');

% Fermeture du port et suppression de l'objet serie
clear ser

