#!/usr/bin/env bash
set -euo pipefail

# easy Viewing Server — Install Script
# Usage: curl -fsSL https://files.hlscloud.de/eview/server/install.sh | bash

INSTALL_DIR="/opt/easyviewing"
IMAGE="ghcr.io/hlsystems/easyviewing-server:latest"
PORT=3000

# ── Colors ─────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC}  $1"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $1"; }
err()   { echo -e "${RED}[error]${NC} $1"; exit 1; }

# ── Banner ─────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}  easy Viewing Server — Installation${NC}"
echo "  -----------------------------------"
echo ""

# ── Preflight checks ──────────────────────────────────────────────────

info "Pruefe Voraussetzungen..."

if ! command -v docker &>/dev/null; then
  err "Docker ist nicht installiert. Bitte installieren Sie Docker: https://docs.docker.com/get-docker/"
fi
ok "Docker gefunden: $(docker --version | head -1)"

if docker compose version &>/dev/null; then
  COMPOSE="docker compose"
  ok "Docker Compose gefunden: $(docker compose version --short)"
elif command -v docker-compose &>/dev/null; then
  COMPOSE="docker-compose"
  ok "Docker Compose gefunden: $(docker-compose --version | head -1)"
else
  err "Docker Compose ist nicht installiert. Bitte installieren Sie Docker Compose."
fi

if ! docker info &>/dev/null; then
  err "Docker-Daemon laeuft nicht. Bitte starten Sie Docker."
fi

# ── Configuration ──────────────────────────────────────────────────────

echo ""

# License key
if [ -t 0 ]; then
  # Interactive mode
  read -rp "$(echo -e "${BOLD}Lizenzschluessel (EV1-...):${NC} ")" LICENSE_KEY
else
  # Non-interactive (piped) — check env variable
  LICENSE_KEY="${EASYVIEWING_LICENSE:-}"
fi

if [ -z "$LICENSE_KEY" ]; then
  warn "Kein Lizenzschluessel angegeben. Sie koennen ihn spaeter in der Web-Oberflaeche eingeben."
fi

# Port
if [ -t 0 ]; then
  read -rp "$(echo -e "${BOLD}Port [${PORT}]:${NC} ")" INPUT_PORT
  PORT="${INPUT_PORT:-$PORT}"
fi

# Install directory
if [ -t 0 ]; then
  read -rp "$(echo -e "${BOLD}Installationsverzeichnis [${INSTALL_DIR}]:${NC} ")" INPUT_DIR
  INSTALL_DIR="${INPUT_DIR:-$INSTALL_DIR}"
fi

# ── Install ────────────────────────────────────────────────────────────

echo ""
info "Installiere nach ${INSTALL_DIR}..."

mkdir -p "$INSTALL_DIR"

cat > "$INSTALL_DIR/docker-compose.yml" <<EOF
services:
  easyviewing:
    image: ${IMAGE}
    ports:
      - "${PORT}:3000"
    volumes:
      - easyviewing-data:/data
      # Host-Verzeichnis zum Durchsuchen (optional, read-only)
      # - /pfad/zu/dateien:/browse:ro
    environment:
      - EASYVIEWING_LICENSE=${LICENSE_KEY}
    restart: unless-stopped

volumes:
  easyviewing-data:
EOF

ok "docker-compose.yml erstellt"

# ── Pull & Start ───────────────────────────────────────────────────────

info "Lade Docker-Image..."
$COMPOSE -f "$INSTALL_DIR/docker-compose.yml" pull

info "Starte easy Viewing Server..."
$COMPOSE -f "$INSTALL_DIR/docker-compose.yml" up -d

# ── Done ───────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}  Installation abgeschlossen!${NC}"
echo ""
echo -e "  Web-Oberflaeche:  ${BOLD}http://localhost:${PORT}${NC}"
echo -e "  Verzeichnis:      ${INSTALL_DIR}"
echo ""
echo "  Nuetzliche Befehle:"
echo "    Logs:     $COMPOSE -f $INSTALL_DIR/docker-compose.yml logs -f"
echo "    Stoppen:  $COMPOSE -f $INSTALL_DIR/docker-compose.yml down"
echo "    Update:   $COMPOSE -f $INSTALL_DIR/docker-compose.yml pull && $COMPOSE -f $INSTALL_DIR/docker-compose.yml up -d"
echo ""
