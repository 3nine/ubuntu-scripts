#!/bin/bash
# Version 1.6
# Copyright (c) 2023 3nine
# Author: 3nine
# License: MIT
# https://github.com/3nine/pi/main/LICENSE.md

# Setze die Farben für die Ausgabe
GREEN='\033[1;92m'
YELLOW='\033[33m'
RED='\033[01;31m'
RESET='\033[m'
HOLD="-"
CM="${GREEN}✓${RESET}"
CROSS="${RED}✗${RESET}"

show_help() {
  GREEN='\033[1;92m'
  YELLOW='\033[33m'
  RED='\033[01;31m'
  RESET='\033[m'
  HOLD="-"
  CM="${GREEN}✓${RESET}"
  CROSS="${RED}✗${RESET}"

  ##### Hilfe
}

show_header() {
clear
cat <<"EOF"
  
   | |  | | | |                     | |          
   | |  | | | |__    _   _   _ __   | |_   _   _ 
   | |  | | | '_ \  | | | | | '_ \  | __| | | | |
   | |__| | | |_) | | |_| | | | | | | |_  | |_| |
    \____/  |_.__/   \__,_| |_| |_|  \__|  \__,_|
    
EOF
}

msg_ok() {
  local msg="$1"
  echo -e "${RESET} ${CM} ${GREEN}${msg}${RESET}"
}

msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YELLOW}${msg}..."
}

msg_error() {
  local msg="$1"
  echo -e "${RESET} ${CROSS} ${RED}${msg}${RESET}"
}

pause() {
  sleep 2 # 2 Sekunden Pause
}

# ----------------------------------------------------------------> Start <----------------------------------------------------------------

# Prüfe ob Arg1 "?" oder "help" ist
if [ "$1" = "?" ] || [ "$1" = "help" ]; then
  show_help
fi

show_header

dialog --title "Network Configuration" --yesno "Do you want to change your current IP address?" 0 0
CHOICE=$?
  case $CHOICE in
  0)
    sudo apt install netplan -y > /dev/null 2>&1
    ipadress=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie eine Ip-Adresse fest. (Format: X.X.X.X)" 0 0 2>&1 >/dev/tty)
    subnet_mask=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie eine Subnetzmaske fest. (Format: /XX)" 0 0 2>&1 >/dev/tty)
    gateway=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie ein Standard-Gateway fest." 0 0 2>&1 >/dev/tty)
    dns1=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie den ersten DNS Server fest." 0 0 2>&1 >/dev/tty)
    dns2=$(sudo dialog --title "IP-Adresse" --inputbox "Legen Sie den zweiten DNS Server fest." 0 0 2>&1 >/dev/tty)
    interface="eth0"

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
    msg_ok "Changed IP address"
  1)
    msg_error "Selected no to change the IP address"
    ;;
  esac

