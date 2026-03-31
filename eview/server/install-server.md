# easy Viewing Server — Installationsanleitung

## Voraussetzungen

- Docker und Docker Compose sind installiert
- Ein gültiger easy Viewing Lizenzschlüssel (EV1-...)

## Installation per Script

Der einfachste Weg: Das Install-Script prüft alle Voraussetzungen, fragt Lizenzschlüssel und Port ab und richtet alles automatisch ein.

```bash
curl -fsSL https://files.hlscloud.de/eview/server/install.sh | bash
```

Für eine automatisierte Installation ohne Rückfragen:

```bash
curl -fsSL https://files.hlscloud.de/eview/server/install.sh | EASYVIEWING_LICENSE=EV1-IhrLizenzschluessel bash
```

Nach der Installation ist der Server unter **http://localhost:3000** erreichbar. Die Konfiguration liegt unter `/opt/easyviewing/docker-compose.yml`.

## Manuelle Installation

1. Erstellen Sie ein Verzeichnis für die Installation:

```bash
mkdir easyviewing && cd easyviewing
```

2. Erstellen Sie eine `docker-compose.yml` Datei mit folgendem Inhalt:

```yaml
services:
  easyviewing:
    image: ghcr.io/hlsystems/easyviewing-server:latest
    ports:
      - "3000:3000"
    volumes:
      - easyviewing-data:/data
    environment:
      - EASYVIEWING_LICENSE=EV1-IhrLizenzschluessel
    restart: unless-stopped

volumes:
  easyviewing-data:
```

3. Tragen Sie Ihren Lizenzschlüssel bei `EASYVIEWING_LICENSE` ein.

4. Starten Sie den Server:

```bash
docker compose up -d
```

5. Öffnen Sie im Browser: **http://localhost:3000**

## Konfiguration

### Port ändern

Um den Server auf einem anderen Port (z.B. 8080) zu betreiben:

```yaml
ports:
  - "8080:3000"
```

### Daten auf dem Host speichern

Statt eines Docker-Volumes können Sie die Daten direkt in einem Host-Verzeichnis ablegen:

```yaml
volumes:
  - /pfad/auf/dem/host:/data
```

### Server-Verzeichnis zum Durchsuchen

Um Dateien direkt vom Host-Dateisystem in der Web-Oberfläche auswählen zu können (z.B. für die Konvertierung), mounten Sie ein Verzeichnis nach `/browse`:

```yaml
volumes:
  - easyviewing-data:/data
  - /pfad/zu/dateien:/browse:ro
```

Das Verzeichnis wird automatisch erkannt und in der Konvertierungsansicht unter "Server-Verzeichnis" angezeigt. Das `:ro` Flag stellt sicher, dass easy Viewing die Dateien nur lesen kann.

## Verwaltung

### Server starten

```bash
docker compose up -d
```

### Server stoppen

```bash
docker compose down
```

### Logs anzeigen

```bash
docker compose logs -f
```

### Update auf eine neue Version

```bash
docker compose pull
docker compose up -d
```

### Daten sichern

Bei Verwendung eines Docker-Volumes:

```bash
docker compose exec easyviewing tar czf - /data > easyviewing-backup.tar.gz
```

Bei Verwendung eines Host-Verzeichnisses sichern Sie einfach das entsprechende Verzeichnis.

## Vollständiges Beispiel

```yaml
services:
  easyviewing:
    image: ghcr.io/hlsystems/easyviewing-server:latest
    ports:
      - "3000:3000"
    volumes:
      - /opt/easyviewing/data:/data
      - /srv/netzwerkdaten:/browse:ro
    environment:
      - EASYVIEWING_LICENSE=EV1-IhrLizenzschluessel
    restart: unless-stopped
```

Dieses Beispiel:

- Speichert Daten unter `/opt/easyviewing/data` auf dem Host
- Stellt `/srv/netzwerkdaten` zum Durchsuchen bereit
- Startet automatisch nach einem Neustart des Hosts

## Fehlerbehebung

### Server startet nicht

Prüfen Sie die Logs:

```bash
docker compose logs
```

### Lizenz ungültig

Wenn beim Start `Warning: EASYVIEWING_LICENSE is expired or invalid.` erscheint, prüfen Sie den Lizenzschlüssel. Die Lizenz kann auch nachträglich in der Web-Oberfläche unter "Einstellungen" eingegeben werden.

### Browse-Verzeichnis nicht sichtbar

Stellen Sie sicher, dass das Verzeichnis als `/browse` gemountet ist und der Container Leserechte hat.
