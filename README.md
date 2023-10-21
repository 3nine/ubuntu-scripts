# Raspberry Pi

Ein selbst erstelltes Skript zum konfigurieren von Raspberry Pi's

# Usage

Sobald dein Raspberry Pi den ersten Start des Images getan hat, kannst du diese Skript verwenden um erstmalig Updates zu installieren, Docker und Docker-Compose zu installieren und einen Cronjob für Automatische Updates zu aktivieren.

```
$ sudo curl -o init.sh https://raw.githubusercontent:com/3nine/pi/main/setup/init.sh && sudo chmod +x init.sh
```

Danach einfach das ```init.sh``` Skript ausführen

# Ziele

- [ ] Füge eine Art GUI hinzu.
- [ ] Erstelle die möglichkeit eine IP-Adress Konfiguration festzulegen.
- [ ] Erstelle eine Auswahl an Services die mit der GUI installiert und konfiguriert werden können.
