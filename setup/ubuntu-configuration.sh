#!/bin/bash
# Version 1.0
# Copyright (c) 2023 3nine
# Author: 3nine
# License: MIT
# https://github.com/3nine/pi/main/LICENSE.md

show_header() {
clear
cat <<EOF
  
   | |  | | | |                     | |          
   | |  | | | |__    _   _   _ __   | |_   _   _ 
   | |  | | | '_ \  | | | | | '_ \  | __| | | | |
   | |__| | | |_) | | |_| | | | | | | |_  | |_| |
    \____/  |_.__/   \__,_| |_| |_|  \__|  \__,_|
    
EOF
}

show_summary() {
  show_header
  echo "Summary:"
  if [ $sum_network ]; then
    msg_ok "Network configured"
  else
    msg_info "No Network configured"
  fi

  echo " "
  read -p "Press any key to exit "
  exit 0
}

# Setze die Farben für die Ausgabe
GREEN='\033[1;92m'
YELLOW='\033[33m'
RED='\033[01;31m'
RESET='\033[m'
HOLD="-"
CM="${GREEN}✓${RESET}"
CROSS="${RED}✗${RESET}"

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

sudo_cache() {
  sudo msg_ok "Please enter Sudo password"
  msg_ok "Sudo Cache enabled"
}

pause() {
  sleep 2 # 2 Sekunden Pause
}

start_configuration() {
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
      sudo chmod 766 /etc/netplan/01-netcfg.yaml
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
        nameservers: [$dns1,$dns2]
EOL
      sudo netplan apply > /dev/null 2>&1
      sudo rm -r /etc/netplan/00-installer-config.yaml > /dev/null 2>&1
      msg_ok "Changed IP address"
      ;;
    1)
      msg_error "Selected no to change the IP address"
      ;;
    esac
  
    dialog --title "Automatic Updates" --yesno "Do you want to activate automatic updates?" 0 0
    CHOICE=$?
    case $CHOICE in
    0)
      sudo mkdir -p /opt/update/
      sudo curl -o /opt/update/auto_update.sh https://raw.githubusercontent.com/3nine/pi/main/setup/auto_update.sh
      sudo chmod +x /opt/update/auto_update.sh
      (crontab -l ; echo "0 0 * * 6 /opt/update/auto_update.sh") | crontab -
      sum_network=true
      ;;
    1)
      sum_network=false
      ;;
    esac

    show_summary
}

show_header
echo -e "This Script will configure the system on your perhaps"
while true; do
  read -p "Start the Ubuntu Configuration Script (y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) clear; exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

start_configuration
