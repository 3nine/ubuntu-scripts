#!/bin/bash
# Version 1.0
# Copyright (c) 2023 3nine
# Author: 3nine
# License: MIT
# https://github.com/3nine/pi/main/LICENSE.md

# Setze die Farben für die Ausgabe
GREEN='\e[32m'
BLUE='\e[34m'
CYAN='\e[36m'
YELLOW='\e[33m'
RED='\e[31m'
RESET='\e[0m'

# --------> Start <--------

install_latest_release() {
  echo "Die neueste Version von Portainer wird heruntergeladen."
  sudo docker pull portainer:latest > /dev/null 2>&1
  echo -e "Das Portainer Volume ${GREEN}portainer_data ${RESET}wird erstellt.${REST}"
  sudo docker volume create portainer_data > /dev/null 2>&1
  echo "Portainer wird nun auf den Ports 8000 und 9443 konfiguriert."
  docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest > /dev/null
  echo -e "${GREEN}Portainer wurde erfolgreich installiert.${REST}"
  echo "Portainer ist erreichbar unter https://localhost:9443."
}

install_latest_release

echo -e "${GREEN}Das Skript wurde erfolgreich ausgeführt."
clear
