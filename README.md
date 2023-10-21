# Ubuntu

Ein selbst erstelltes Skript zum konfigurieren von Ubuntu Systemen

# Usage

Sobald dein Raspberry Pi den ersten Start des Images getan hat, kannst du diese Skript verwenden um erstmalig Updates zu installieren, Docker und Docker-Compose zu installieren und einen Cronjob für Automatische Updates zu aktivieren.

```
$ sudo curl -o init.sh https://raw.githubusercontent:com/3nine/pi/main/setup/init.sh && sudo chmod +x init.sh
```

Danach einfach das ```init.sh``` Skript ausführen

# Targets

- [x] Füge eine Art GUI hinzu.
- [x] Erstelle die möglichkeit eine IP-Adress Konfiguration festzulegen.
- [x] Erstelle die möglichkeit eine Firewall zu installieren und den SSH Zugang zu ermöglichen
- [ ] Erstelle eine Auswahl an Services die mit der GUI installiert und konfiguriert werden können.
- [ ] Erstelle eine Auswahl an Services die mit der GUI deinstalliert werden können sowie die Firewallregeln
