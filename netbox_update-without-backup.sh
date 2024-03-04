#!/bin/bash
# Version 1.0
# Copyright (c) 2023 3nine
# Author: 3nine
# License: MIT
# https://github.com/3nine/pi/main/LICENSE.md

#######################################################################
#                                                                     #
#                       Festlegen der Variablen                       #
#                                                                     #
#######################################################################

# Setze die Farben für die Ausgabe
GREEN='\e[32m'
BLUE='\e[34m'
CYAN='\e[36m'
YELLOW='\e[33m'
RED='\e[31m'
RESET='\e[0m'

# Format nachdem geprüft wird
pattern="^[0-9]+\.[0-9]+\.[0-9]+$"
# GitHub-Repository
repository="netbox-community/netbox"

#######################################################################
#                                                                     #
#                                 Methoden                            #
#                                                                     #
#######################################################################

show_help() {
  GREEN='\e[32m'
  BLUE='\e[34m'
  CYAN='\e[36m'
  YELLOW='\e[33m'
  RED='\e[31m'
  RESET='\e[0m'

  echo -e "${GREEN}Dieses Skript fürt automatische Updates sowie Konfigurationen durch${RESET}"
  echo -e "${GREEN}Es aktualisiert die Paketquellen, führt ein Paketupgrade durch und bietet die Option, bestimmte Services zu installieren.${RESET}"
  echo -e "${CYAN}Verwendung:${RESET}"
  echo -e "${CYAN}  ./netbox_update.sh                  - Führt das Skript aus.${RESET}"
  echo -e "${CYAN}  ./netbox_update.sh help or ?        - Zeigt diese Hilfe an.${RESET}"
  exit 0
}

check_version_format() {
  local version="$1"
  if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return 0  # Das Format ist korrekt
  else
    return 1  # Das Format ist falsch
  fi
}

check_powershell_installed() {
  if dpkg -l | grep "powershell"
    return 0
  else
    sudo apt install powershell
  fi
}

#######################################################################
#                                                                     #
#                           Start des Skripts                         #
#                                                                     #
#######################################################################

# Prüfe ob Arg1 "?" oder "help" ist
if [ "$1" = "?" ] || [ "$1" = "help" ]; then
  show_help
fi

OLDVER=$(sudo dialog --title "Alte Version" --inputbox "Bitte gebe die Version, auf der NetBox momentan benutzt wird. (Format: X.X.X)" 0 0 2>&1 >/dev/tty)
NEWVER=$(sudo dialog --title "Neue Version" --inputbox "Bitte gebe die Version an, auf der NetBox künftig laufen soll.. (Format: X.X.X)" 0 0 2>&1 >/dev/tty)

# Überprüfung des Formats für beide Versionen
if check_version_format "$NEWVER" && check_version_format "$OLDVER"; then
  echo "${GREEN}Beide Versionen haben das korrekte Format.${RESET}"
else
  clear
  echo "${RED}Eine oder beide Versionen haben nicht das korrekte Format. Bitte geben Sie gültige Versionen im Format x.x.x ein.${RESET}"
  exit 1
fi

# Überprüfen, ob die Version auf GitHub gefunden wird
github_url="https://api.github.com/repos/$repository/releases/tags/v$NEWVER"
response=$(curl -s "$github_url")
if [[ "$response" == *"Not Found"* ]]; then
  clear
  echo "${RED}Die Version $NEWVER wurde auf GitHub nicht gefunden.${RESET}"
else
  clear
  # Erstelle einen Prüfpunkt mit dem Namen "Vor Update vX.X.X"
  check_powershell_installed
  HYPERV_HOST="Hyper-V06"
  VM_NAME="netbox_test"
  SNAPSHOTNAME=date +%s "Vor Update v" $OLDVERPSHOT
  BACKUP_USER=""

  # Pwershell Befehl zum erstellen des Prüfpunkts
  PS_COMMAND="Checkpoint-VM -Name $VM_NAME" -SnapshotName $SNAPSHOTNAME

  # Powershell-Befehl ausführen
  ssh $BACKUP_USER@$HYPERV_HOST powershell.exe -Command "$PS_COMMAND"
  
  echo "${GREEN}Die Version $NEWVER wurde auf GitHub gefunden.${RESET}"
  # Downloade gefundene Version von GitHub, entpacke sie und setze das Verzeichnis als neuen Symlink
  wget https://github.com/netbox-community/netbox/archive/v$NEWVER.tar.gz
  sudo tar -xzf v$NEWVER.tar.gz -C /opt
  sudo ln -sfn /opt/netbox-$NEWVER/ /opt/netbox

  # Kopiere local_requirements, configuration.py und ldap_config.py (wenn vorhanden)
  sudo cp /opt/netbox-$OLDVER/local_requirements.txt /opt/netbox/
  sudo cp /opt/netbox-$OLDVER/netbox/netbox/configuration.py /opt/netbox/netbox/netbox/
  sudo cp /opt/netbox-$OLDVER/netbox/netbox/ldap_config.py /opt/netbox/netbox/netbox/

  # Kopiere die hochgeladenen Dateien
  sudo cp -pr /opt/netbox-$OLDVER/netbox/media/ /opt/netbox/netbox/

  # Kopiere die Custom Skripts und Reports
  sudo cp -r /opt/netbox-$OLDVER/netbox/scripts /opt/netbox/netbox/
  sudo cp -r /opt/netbox-$OLDVER/netbox/reports /opt/netbox/netbox/
  
  # Kopiere die NetBox Topologie View Images
  iamges="/opt/netbox-$OLDVER/netbox/static/netbox_topology_views/img"
  dialog --title "Topologie View" --yesno "Ist Topologie View installiert?" 0 0
  response=$?
  case $response in
    0)
      sudo cp -r /opt/netbox-$OLDVER/netbox/static/netbox_topology_views/img /opt/netbox/netbox/static/netbox_topology_views/
      ;;
    1)
      echo "Topologie View ist nicht installiert, daher werden in diesem Schritt keine Dateien kopiert"
      ;;
    255)
      exit 1
      ;;
  esac
  
  # Kopiere die gunicorn.py konfiguration
  sudo cp /opt/netbox-$OLDVER/gunicorn.py /opt/netbox/

  # Führe das upgrade Skript aus
  sudo /opt/netbox/upgrade.sh

  # Starte die NetBox Services neu
  sudo systemctl restart netbox netbox-rq

  # Erstelle einen Prüfpunkt mit dem Namen "Nach Update vX.X.X"

fi
