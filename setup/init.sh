#!/bin/bash
# Version 1.6
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
  echo -e "${CYAN}  ./scriptname              - Führt das Skript aus.${RESET}"
  echo -e "${CYAN}  ./scriptname help or ?    - Zeigt diese Hilfe an.${RESET}"
  exit 0
}

check_netplan_installed() {
  if (dpkg -l | grep -q "netplan.io"); then
    netplan_installed=true
    pause
  else
    netplan_installed=false
    pause
  fi
}

check_docker_installed() {
  if dpkg -l | grep -q "docker-ce"; then
    docker_installed=true
    pause
  else
    docker_installed=false
    pause
  fi
}

check_docker_compose_installed() {
  if dpkg -l | grep -q "docker-compose-plugin"; then
    docker_compose_installed=true
    pause
  else
    docker_compose_installed=false
    pause
  fi
}

install_docker() {
  echo -e "${BLUE}Installiere Docker...${RESET}"
  sudo curl -sSL https://get.docker.com/ | CHANNEL=stable sh > /dev/null 2>&1
  echo -e "${BLUE}Docker wurde installiert.${RESET}"
  pause
}

install_docker_compose() {
  echo -e "${BLUE}Installiere Docker-Compose...${RESET}"
  sudo apt install docker-compose-plugin > /dev/null  2>&1
  echo -e "${BLUE}Docker-Compose wurde installiert.${RESET}"
  pause
}

install_netplan() {
  echo -e "${BLUE}Installiere Netplan.io${RESET}"
  sudo apt install netplan.io -y > /dev/null 2>&1
  echo -e "${BLUE}Netplan.io wurde installiert.${RESET}"
  pause
}

pause() {
  sleep 2 # 2 Sekunden Pause
}

autoremove() {
  echo -e "${BLUE}Überprüfe, ob Pakete zum Entfernen verfügbar sind.${RESET}"
  autoremove_output=$(sudo apt-get autoremove -s > /dev/null 2>&1)

  if [[ "$autoremove_output" == *"Die folgenden Pakete werden entfernt"* ]]; then
    echo -e "${BLUE}Bereinigung wird durchgeführt, um ungenutzte Pakete zu entfernen.${RESET}"
    sudo apt-get autoremove -y > /dev/null 2>&1
    echo -e "${BLUE}Bereinigung abgeschlossen.${RESET}"
  else
    echo -e "${YELLOW}Keine Pakete zum Entfernen gefunden.${RESET}"
  fi
}

# --------> Start <--------

# Prüfe ob Arg1 "?" oder "help" ist
if [ "$1" = "?" ] || [ "$1" = "help" ]; then
  show_help
fi

echo -e "Grundinstallation eines Pi's"
# Führt ein Update der Paketquellen durch
echo "Aktualisiere Paketquellen"
sudo apt update > /dev/null 2>&1
echo -e "${GREEN}Aktualisierung abgeschlossen${RESET}"

# Führt ein Upgrade der Paketquellen durch
echo "Upgrade der installierten Paketquellen"
sudo apt update > /dev/null 2>&1
echo -e "${GREEN}Upgrade abgeschlossen${RESET}"

# Aufruf function autoremove
autoremove

check_docker_installed
if $docker_installed; then
  echo -e "${YELLOW}Docker ist bereits installiert, daher wird dieser Schritt übersprungen!${RESET}"
  pause
else
  # Abfrage Docker Installation
  dialog --title "Docker Installation" --yesno "Möchten Sie Docker installieren?" 0 0
  response_docker=$?
  case $response_docker in
    0)
      clear
      # Benutzer möchte Docker installieren
      install_docker

      # Teste ob Docker-Compose mit installiert wurde
      check_docker_compose_installed
      if $docker_compose_installed; then
        clear
      else
        # Abfrage Docker-Compose Installation
         dialog --title "Docker-Compose Installation" --yesno "Möchten Sie Docker-Compose  installieren?" 0 0
         response_docker_compose=$?
         case $response_docker_compose in
           0)
             clear
             install_docker_compose ;; # Docker Compose wurde nicht installiert aber der Benutzer möchte es installieren
           1)
             echo -e "${GREEN}Docker wurde nicht installiert.${RESET}" ;; # Benutzer möchte Docker-Compose nicht installieren
           255)
             echo -e "${RED}Abbruch.${RESET}" ;; # Benutzer hat abbruch gewählt
         esac
      fi
      ;;
    1)
      echo -e "${GREEN}Docker wird nicht installiert.${RESET}" ;; #Benutzer möchte Docker nicht installieren
    255)
      echo -e "${RED}Abbruch.${RESET}" ;; # Benutzer hat abbruch gewählt
  esac
fi

# Abfrage ob eine IP-Adress Konfigraution stattfinden soll
dialog --title "IP-Adresse" --yesno "Möchten Sie eine IP-Adresse festlegen?" 0 0
response_ipadress=$?
case $response_ipadress in
  0)
    check_netplan_installed
    if $netplan_installed; then
      echo "Netplan ist bereits installiert, daher wird dieser Schritt übersprungen"
    else
      clear
      install_netplan
    fi
    # Sammle Informationen dazu welche IP verwendet werden soll
    ipadress=$(dialog --title "IP-Adresse" --inputbox "Legen Sie eine IP-Adresse fest. (Format: X.X.X.X)" 0 0)
    subnet_mask=$(dialog --title "IP-Adresse" --inputbox "Legen Sie eine Subnetzmaske fest. (Format: /XX)" 0 0)
    gateway=$(dialog --title "IP-Adresse" --inputbox "Legen Sie ein Standard-Gateway fest." 0 0)

    # Interface festlegen
    interface="eth0"

    # Erstellen der Konfiguration mit Netplan
    sudo touch /etc/netplan/01-netcfg.yaml
    cat > /etc/netplan/01-netcfg.yaml <<EOL
network:
  version: 2
  ethernets:
    $interface:
      addresses: [$ipaddress/$subnet_mask]
      gateway4: $gateway
EOL


    # Konfiguration anwenden
    sudo netplan apply

    if [ $? -eq 0 ]; then
      echo -e "${GREEN}Die Konfiguration wurde erfolgreich übernommen.${RESET}"
    else
      echo -e "${RED}Die Konfiguration konnte nicht übernommen werden.${RESET}"
    fi
    ;;
  1)
    echo -e "${GREEN}Die IP-Konfiguration wurde nicht verändert.${RESET}" ;;
  255)
    echo -e "${YELLOW}Abbruch.${RESET}" ;;
esac
























# Autoupdate Abfrage
dialog --title "Autoupdate aktivieren" --yesno "Möchten Sie Autoupdate aktivieren? Wenn ja, werden wöchentliche Updates automatisch Samstags um 00:00 Uhr durchgeführt." 0 0

response_autoupdate=$?
case $response_autoupdate in
  0)
    echo -e "${YELLOW}Autoupdate wird aktiviert.${RESET}"
    sudo mkdir -p /opt/update/
    sudo curl -o /opt/update/auto_update.sh https://raw.githubusercontent.com/3nine/pi/setup/auto_update.sh
    sudo chmod +x /opt/update/auto_update.sh
    (crontab -l ; echo "0 0 * * 6 /opt/update/auto_update.sh") | crontab -
    echo -e "${BLUE}Autoupdate aktiviert.${RESET}"
    ;;
  1)
    echo -e "${GREEN}Autoupdate wird nicht aktiviert.${RESET}" ;;
  255)
    echo -e "${YELLOW}Abbruch.${RESET}" ;;
esac

# Benutzerabfrage, ob das System heruntergefahren werden soll
dialog --title "Skript abgeschlossen" --yesno "Das Skript wurde abgeschlossen. Möchten Sie das System neu starten?" 0 0
# Überprüft die Antwort auf die Benutzerabfrage
response_restart=$?
case $response_restart in
  0)
    echo -e "${GREEN}Der Raspberry Pi wird neu gestartet.${RESET}"
    clear
    sudo shutdown now ;; # Benutzer hat "Ja" ausgewählt, das System wird heruntergefahren
  1)
    echo -e "${GREEN}Der Raspberry Pi bleibt eingeschaltet.${RESET}" ;; # Benutzer hat "Nein" ausgewählt, das Skript wird beendet
  255)
    echo -e "${RED}Abbruch.${RESET}" ;; # Benutzer hat Abbruch ausgewählt
esac

#Lösche das Konsolenfenster
clear
