# Automatisches Update-Skript
# Erstellen eines cronjobs
crontab -e
1
# Aktualisiere die Paketquellen
sudo apt-get update -y > /dev/null 2>&1

# Führe ein Upgrade der installierten Pakete durch
sudo apt-get upgrade -y > /dev/null 2>&1

# Führe autoremove durch
sudo apt-get autoremove -y > /dev/null 2>&1

