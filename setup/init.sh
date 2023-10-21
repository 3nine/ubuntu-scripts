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
  else
    netplan_installed=false
  fi
}

check_ufw_installed() {
  if (dpkg -l | grep "ufw"); then
    ufw_installed=true
  else
    ufw_installed=false
  fi
}

check_docker_installed() {
  if dpkg -l | grep -q "docker-ce"; then
    docker_installed=true
  else
    docker_installed=false
  fi
}

check_docker_compose_installed() {
  if dpkg -l | grep -q "docker-compose-plugin"; then
    docker_compose_installed=true
  else
    docker_compose_installed=false
  fi
}

install_ufw() {
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Staring installation of UFW." >> /tmp/pi/logs/log.txt
  sudo apt install ufw > /dev/null 2>&1
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - FINISHED - installation of UFW Finished." >> /tmp/pi/logs/log.txt

install_docker() {
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Starting installation of Docker." >> /tmp/pi/logs/log.txt
  echo -e "${BLUE}Installiere Docker...${RESET}"
  sudo curl -sSL https://get.docker.com/ | CHANNEL=stable sh > /dev/null 2>&1
  echo -e "${BLUE}Docker wurde installiert.${RESET}"
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - FNISHED - Installation of Docker Finished." >> /tmp/pi/logs/log.txt
}

install_docker_compose() {
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Starting installation of Docker-Compose." >> /tmp/pi/logs/log.txt
  echo -e "${BLUE}Installiere Docker-Compose...${RESET}"
  sudo apt install docker-compose-plugin > /dev/null  2>&1
  echo -e "${BLUE}Docker-Compose wurde installiert.${RESET}"
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - FNISHED - Installation of Docker-Compose Finished." >> /tmp/pi/logs/log.txt
}

install_netplan() {
echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Starting installation of Netplan." >> /tmp/pi/logs/log.txt
  echo -e "${BLUE}Installiere Netplan.io${RESET}"
  sudo apt install netplan.io -y > /dev/null 2>&1
  echo -e "${BLUE}Netplan.io wurde installiert.${RESET}"
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - FNISHED - Installation of Netplan Finished." >> /tmp/pi/logs/log.txt
}

pause() {
  sleep 2 # 2 Sekunden Pause
}

autoremove() {
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Checking if packages are available for removal." >> /tmp/pi/logs/log.txt
  echo -e "${BLUE}Überprüfe, ob Pakete zum Entfernen verfügbar sind.${RESET}"
  autoremove_output=$(sudo apt-get autoremove -s > /dev/null 2>&1)

  if [[ "$autoremove_output" == *"Die folgenden Pakete werden entfernt"* ]]; then
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - The following packages are being removed." >> /tmp/pi/logs/log.txt
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Cleanup is performed to remove unused packages." >> /tmp/pi/logs/log.txt
    echo -e "${BLUE}Bereinigung wird durchgeführt, um ungenutzte Pakete zu entfernen.${RESET}"
    sudo apt-get autoremove -y > /dev/null 2>&1
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - FINISHED - Cleanup completed." >> /tmp/pi/logs/log.txt
    echo -e "${BLUE}Bereinigung abgeschlossen.${RESET}"
  else
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - No Packages found for removal." >> /tmp/pi/logs/log.txt
    echo -e "${YELLOW}Keine Pakete zum Entfernen gefunden.${RESET}"
  fi
}

# --------> Start <--------

# Prüfe ob Arg1 "?" oder "help" ist
if [ "$1" = "?" ] || [ "$1" = "help" ]; then
  show_help
fi

clear
sudo mkdir -p /tmp/pi/logs
sudo touch /tmp/pi/logs/log.txt

echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Starting Init.sh." >> /tmp/pi/logs/log.txt
echo -e "Grundinstallation eines Pi's"
# Führt ein Update der Paketquellen durch
echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Updating package sources." >> /tmp/pi/logs/log.txt
echo "Aktualisiere Paketquellen"
sudo apt update > /dev/null 2>&1
echo -e "$(date '+%Y-%m-%d %H:%M:%S') - FINISHED - Update completed." >> /tmp/pi/logs/log.txt
echo -e "${GREEN}Aktualisierung abgeschlossen${RESET}"

# Führt ein Upgrade der Paketquellen durch
echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Upgrading installed package sources." >> /tmp/pi/logs/log.txt
echo "Upgrade der installierten Paketquellen"
sudo apt update > /dev/null 2>&1
echo -e "$(date '+%Y-%m-%d %H:%M:%S') - FINISHED - Upgrading completed." >> /tmp/pi/logs/log.txt
echo -e "${GREEN}Upgrade abgeschlossen${RESET}"

# Aufruf function autoremove
autoremove

check_docker_installed
if $docker_installed; then
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Docker is already installed, so this step is skipped" >> /tmp/pi/logs/log.txt
  echo -e "${YELLOW}Docker ist bereits installiert, daher wird dieser Schritt übersprungen!${RESET}"
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
             echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Docker was not installed." >> /tmp/pi/logs/log.txt
             echo -e "${GREEN}Docker wurde nicht installiert.${RESET}" ;; # Benutzer möchte Docker-Compose nicht installieren
           255)
             echo -e "$(date '+%Y-%m-%d %H:%M:%S') - WARNING - User chose to abort." >> /tmp/pi/logs/log.txt
             echo -e "${RED}Abbruch.${RESET}" ;; # Benutzer hat abbruch gewählt
         esac
      fi
      ;;
    1)
      echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Docker will not be installed." >> /tmp/pi/logs/log.txt
      echo -e "${GREEN}Docker wird nicht installiert.${RESET}" ;; #Benutzer möchte Docker nicht installieren
    255)
      echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - User chose to abort." >> /tmp/pi/logs/log.txt
      echo -e "${RED}Abbruch.${RESET}" ;; # Benutzer hat abbruch gewählt
  esac
fi

# Abfrage ob die Firewall installiert und aktiviert werden soll
dialog --title "Firewall" --yesno "Möchten Sie die Firewall aktivieren?" 0 0
response_firewall=$?
case $response_firewall in
  0)
    check_ufw_installed
    if $ufw_installed; then
      clear
      dialog --title "Firewall installation" --msgbox "Firewall konnte nicht installiert werden, da sie schon installiert ist" 0 0
      echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - UFW is already installed,so this step is skipped." >> /tmp/pi/logs/log.txt
    else
      clear
      install_ufw
    fi
    # Abfrage ob der Zugang per SSH erlaubt sein soll
    dialog --title "Firewall Konfiguration" --yesno "Soll der Zugang per SSH erlaubt sein?" 0 0
    response_ssh=$?
    case $response_ssh in
      0)
        sudo ufw allow ssh
        echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - SSH is now allowed in UFW" >> /tmp/pi/logs/log.txt
        dialog --title "Firewall Konfiguration" --msgbox "SSH Zugang ist jetzt erlaubt."
        sudo ufw enable
        echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - UFW is now enabled" >> /tmp/pi/logs/log.txt
        dialog --title "Firewall Konfiguration" --msgbox "Firewall ist jetzt aktiviert"
        ;;
      1)
        echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - SSH is not allowed in UFW" >> /tmp/pi/logs/log.txt
        dialog --title "Firewall Konfiguration" --msgbox "SSH Zugang ist nicht erlaubt."
        ;;
      255)
        echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - User chose to abort" >> /tmp/pi/logs/log.txt
        ;;
    esac
    ;;
  1)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - UFW is now disabled" >> /tmp/pi/logs/log.txt
    dialog --title "Firewall Konfiguration" --msgbox "Firewall soll nicht aktiviert werden."
    ;;
  255)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - User chose to abort" >> /tmp/pi/logs/log.txt
    ;;
esac  

# Abfrage ob eine IP-Adress Konfiguration stattfinden soll
dialog --title "IP-Adresse" --yesno "Möchten Sie eine IP-Adresse festlegen?" 0 0
response_ipadress=$?
case $response_ipadress in
  0)
    check_netplan_installed
    if $netplan_installed; then
      clear
      echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Netplan is already installed,so this step is skipped." >> /tmp/pi/logs/log.txt
      echo "Netplan ist bereits installiert, daher wird dieser Schritt übersprungen"
    else
      clear
      install_netplan
    fi
    # Sammle Informationen dazu welche IP verwendet werden soll
    ipadress=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie eine Ip-Adresse fest. (Format: X.X.X.X)" 0 0 2>&1 >/dev/tty)
    subnet_mask=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie eine Subnetzmaske fest. (Format: /XX)" 0 0 2>&1 >/dev/tty)
    gateway=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie ein Standard-Gateway fest." 0 0 2>&1 >/dev/tty)
    dns1=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie den ersten DNS Server fest." 0 0 2>&1 >/dev/tty)
    dns2=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie den zweiten DNS Server fest." 0 0 2>&1 >/dev/tty)

    # Interface festlegen
    interface="eth0"

    # Erstellen der Konfiguration mit Netplan
    sudo touch /etc/netplan/01-netcfg.yaml
    sudo chmod 600 /etc/netplan/01-netcfg.yaml
    sudo cat > /etc/netplan/01-netcfg.yaml <<EOL
network:
  version: 2
  ethernets:
    $interface:
      addresses:
        - $ipadress/$subnet_mask
      routes:
        - to: default
          via: $gateway
      nameservers: [$dns1,dns2]
EOL

    # Konfiguration anwenden
    sudo netplan apply
    clear

    if [ $? -eq 0 ]; then
      echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - The configuration was successfully applied." >> /tmp/pi/logs/log.txt
      echo -e "${GREEN}Die Konfiguration wurde erfolgreich übernommen.${RESET}"
    else
      echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - The configuration could not be applied." >> /tmp/pi/logs/log.txt
      echo -e "${RED}Die Konfiguration konnte nicht übernommen werden.${RESET}"
    fi
    ;;
  1)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - The IP configuration was not changed." >> /tmp/pi/logs/log.txt
    echo -e "${GREEN}Die IP-Konfiguration wurde nicht verändert.${RESET}" ;;
  255)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - User chose to abort." >> /tmp/pi/logs/log.txt
    echo -e "${YELLOW}Abbruch.${RESET}" ;;
esac

# Autoupdate Abfrage
dialog --title "Autoupdate aktivieren" --yesno "Möchten Sie Autoupdate aktivieren? Wenn ja, werden wöchentliche Updates automatisch Samstags um 00:00 Uhr durchgeführt." 0 0

response_autoupdate=$?
case $response_autoupdate in
  0)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Automatic Updates are activated." >> /tmp/pi/logs/log.txt
    echo -e "${YELLOW}Automatische Uodates werden aktiviert.${RESET}"
    sudo mkdir -p /opt/update/
    sudo curl -o /opt/update/auto_update.sh https://raw.githubusercontent.com/3nine/pi/main/setup/auto_update.sh
    sudo chmod +x /opt/update/auto_update.sh
    (crontab -l ; echo "0 0 * * 6 /opt/update/auto_update.sh") | crontab -
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Automatic Updates are enabled." >> /tmp/pi/logs/log.txt
    echo -e "${BLUE}Automatische Updates sind aktiviert.${RESET}"
    ;;
  1)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Automatic updates are not activated." >> /tmp/pi/logs/log.txt
    echo -e "${GREEN}Automatische Updates werden nicht aktiviert.${RESET}" ;;
  255)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - User chose to abort." >> /tmp/pi/logs/log.txt
    echo -e "${YELLOW}Abbruch.${RESET}" ;;
esac

# Benutzerabfrage, ob das System heruntergefahren werden soll
dialog --title "Skript abgeschlossen" --yesno "Das Skript wurde abgeschlossen. Möchten Sie das System neu starten?" 0 0
# Überprüft die Antwort auf die Benutzerabfrage
response_restart=$?
case $response_restart in
  0)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Restarting Device." >> /tmp/pi/logs/log.txt
    echo -e "${GREEN}Der Raspberry Pi wird neu gestartet.${RESET}"
    clear
    sudo shutdown now ;; # Benutzer hat "Ja" ausgewählt, das System wird heruntergefahren
  1)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - Device stays on." >> /tmp/pi/logs/log.txt
    echo -e "${GREEN}Der Raspberry Pi bleibt eingeschaltet.${RESET}" ;; # Benutzer hat "Nein" ausgewählt, das Skript wird beendet
  255)
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - INFO - User chose to abort." >> /tmp/pi/logs/log.txt
    echo -e "${RED}Abbruch.${RESET}" ;; # Benutzer hat Abbruch ausgewählt
esac

#Lösche das Konsolenfenster
clear
