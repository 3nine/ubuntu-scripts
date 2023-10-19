#!/bin/bash
# Version 1.0
# Copyright (c) 2023 tteck
# Author: 3nine
# License: MIT
# https://github.com/3nine/pi/auto_update.sh

# Aktualisiere die Paketquellen
sudo apt-get update -y > /dev/null 2>&1

# Führe ein Upgrade der installierten Pakete durch
sudo apt-get upgrade -y > /dev/null 2>&1

# Führe autoremove durch
sudo apt-get autoremove -y > /dev/null 2>&1
