

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
