#!/bin/bash
# Version 1.0
# Copyright (c) 2023 3nine
# Author: 3nine
# License: MIT
# https://github.com/3nine/pi/main/LICENSE.md

# Format nachdem geprüft wird
pattern="^[0-9]+\.[0-9]+\.[0-9]+$"
# GitHub-Repository
repository="netbox-community/netbox"

# Setze die Farben für die Ausgabe
GREEN='\e[32m'
BLUE='\e[34m'
CYAN='\e[36m'
YELLOW='\e[33m'
RED='\e[31m'
RESET='\e[0m'

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
  echo -e "${CYAN}  ./netbox_update.sh <old version> <new version>              - Führt das Skript aus.${RESET}"
  echo -e "${CYAN}  ./netbox_update.sh help or ?                                - Zeigt diese Hilfe an.${RESET}"
  exit 0
}

# Funktion zur Überprüfung des Formats "x.x.x"
check_version_format() {
  local version="$1"
  if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return 0  # Das Format ist korrekt
  else
    return 1  # Das Format ist falsch
  fi
}

# --------> Start <--------

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

  # Kopiere die gunicorn.py konfiguration
  sudo cp /opt/netbox-$OLDVER/gunicorn.py /opt/netbox/

  # Führe das upgrade Skript aus
  sudo ./upgrade.sh

  # Starte die NetBox Services neu
  sudo systemctl restart netbox netbox-rq

fi

clear
