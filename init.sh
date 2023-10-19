

# Setze die Farben für die Ausgabe
GREEN='\e[32m'
BLUE='\e[34m'
CYAN='\e[36m'
YELLOW='\e[33m'
RESET='\e[0m'

show_help() {
  GREEN='\e[32m'
  BLUE='\e[34m'
  CYAN='\e[36m'
  YELLOW='\e[33m'
  RESET='\e[0m'
  
  echo -e "${GREEN}Dieses Skript fürt automatische Updates sowie Konfigurationen durch${RESET}"
  echo -e "${GREEN}Es aktualisiert die Paketquellen, führt ein Paketupgrade durch und bietet die Option, bestimmte Services zu installieren.${RESET}"
  echo -e "${CYAN}Verwendung:${RESET}"
  echo -e "${CYAN}  ./scriptname              - Führt das Skript aus.${RESET}"
  echo -e "${CYAN}  ./scriptname help or ?    - Zeigt diese Hilfe an.${RESET}"
  exit 0
}

check_docker_installed() {
  if dpkg -l | grep -q "docker"; then
    docker_installed=true
  else
    docker_installed=false
  fi
}

check_docker-compose_installed() {
  if dpkg -l | grep -q "docker-compose"; then
    docker-compose_installed=true
  else
    docker-compose_installed=false
  fi
}

install_docker() {
  echo -e "${BLUE}Installiere Docker...${RESET}"
  sudo curl -sSL https://get.docker.com/ | CHANNEL=stable sh > /dev/null 2>&1
  echo -e "${BLUE}Docker wurde installiertt.${RESET}"
}

install_docker-compose() {
  echo -e "${BLUE}Installiere Docker-Compose...${RESET}"
  sudo apt install docker-compose-plugin
  echo -e "${BLUE}Docker-Compose wurde installiert.${RESET}"
}

pause() {
  sleep 2 # 2 Sekunden Pause
}

autoremove() {
  echo -e "${BLUE}Schritt 3: Überprüfe, ob Pakete zum Entfernen verfügbar sind.${RESET}"
  autoremove_output=$(sudo apt-get autoremove -s > /dev/null 2>&1)

  if [[ "$autoremove_output" == *"Die folgenden Pakete werden entfernt"* ]]; then
    echo -e "${BLUE}Schritt 3: Bereinigung wird durchgeführt, um ungenutzte Pakete zu entfernen.${RESET}"
    sudo apt-get autoremove -y > /dev/null 2>&1
    echo -e "${BLUE}Schritt 3: Bereinigung abgeschlossen.${RESET}"
  else
    echo -e "${YELLOW}Keine Pakete zum Entfernen gefunden. Der Schritt 3 wird übersprungen.${RESET}"
  fi
}

# --------> Start <--------

# Prüfe ob Arg1 "?" oder "help" ist
if [ "$1" = "?" ] || [ "$1" = "help" ]; then
  show_help
fi

sudo echo "Um dieses Skript auszuführen, sind Root Berechtigungen nötig."

echo -e "Grundinstallation eines Pi's"














