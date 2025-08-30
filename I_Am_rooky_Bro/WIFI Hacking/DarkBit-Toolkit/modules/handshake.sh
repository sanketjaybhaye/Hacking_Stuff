NAME="Capture Handshake (Placeholder)"
DESCRIPTION="Start capture & deauth for handshake (lab use only)"

run() {
  read -p "Enter target BSSID: " BSSID
  read -p "Enter channel: " CH
  CAPFILE="$LOGDIR/handshake-$(date +%F-%H%M)"
  log "Capturing handshake for $BSSID on CH $CH"
  echo "[*] (PLACEHOLDER) Insert airodump + aireplay logic here"
  echo "[*] Save capture to: $CAPFILE.cap"
}
