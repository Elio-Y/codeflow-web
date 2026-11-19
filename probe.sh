#!/bin/bash
# Komari probe runner (Altare Procfile process).
# Needs KOMARI_ENDPOINT and KOMARI_TOKEN from the app environment.
if [ -z "$KOMARI_TOKEN" ] || [ -z "$KOMARI_ENDPOINT" ]; then
  echo "probe: KOMARI_TOKEN/KOMARI_ENDPOINT not set, idling"
  while true; do sleep 3600; done
fi
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "probe: unsupported arch $ARCH"; while true; do sleep 3600; done ;;
esac
BIN="./komari-agent"
if [ ! -x "$BIN" ]; then
  URL="https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-${ARCH}"
  echo "probe: downloading agent"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$BIN" "$URL" || rm -f "$BIN"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$BIN" "$URL" || rm -f "$BIN"
  fi
  chmod +x "$BIN" 2>/dev/null || true
fi
while true; do
  "$BIN" -e "$KOMARI_ENDPOINT" -t "$KOMARI_TOKEN" || sleep 10
done
