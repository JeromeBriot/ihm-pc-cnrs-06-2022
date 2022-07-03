# Développement d’Interfaces Homme-Machine (IHM) sur PC en programmation scientifique (Python, MATLAB, GNU Octave, Scilab)

## Présentation
Ce dépôt contient des exemples pour apprendre à créer des IHM sur PC avec les langages suivants :
- Python
- MATLAB
- GNU Octave
- Scilab

Le rôle de ces IHM est d'interfacer un PC avec des dispositifs électroniques.

Les codes présentés ici ont été développés dans le cadre de la [5ème rencontre annuelle du réseau régional des électroniciens d'Occitanie](https://occitanie.electroniciens.cnrs.fr/5eme-rencontre-des-electroniciens-et-instrumentalistes/) (CNRS - France) du 29 juin 2022.

### Prérequis
#### Matériel
Tous les codes sont multi-plateformes et ont été testés avec les systèmes d'exploitation suivants :
- Windows 10
- macOS Monterey
- Xubuntu 22.04

Le dispositif interfacé avec le PC est une carte Arduino Uno. La plupart des exemples n'utilisent que la LED présente sur la carte. Certains exemples plus évolués nécessitent du matériel supplémentaire.

#### Logiciel

![](/images/langages.png)

Liens vers les bibliothèques utilisées :
- [pySerial](https://pypi.org/project/pyserial/)
- [Instrument Control Package](https://octave.sourceforge.io/instrument-control/index.html)
- [Serial Communication Toolbox](https://atoms.scilab.org/toolboxes/serial)

### Contenu
#### Dossier exemples
Ce dossier contient des exemples de base pour apprendre à intéragir avec la carte Aduino Uno via une communciation UART et grâce à des IHM en Python, MATLAB, GNU Octave et Scilab.
#### Dossier demos
Ce dossier contient des exemples plus évolués pour intéragir en temps réel et en continu avec la carte Arduino Uno.
## Historique

v1.0.0 - 02/07/2022

## Support
Pour toute question ou remarque, envoyer un email à jbtechlab@gmail.com