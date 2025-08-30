NAME="Scan Networks"
DESCRIPTION="Scan nearby Wi-Fi networks and log results"

run() {
  log "Running network scan..."
  OUT="$LOGDIR/scan-$(date +%F-%H%M).log"
  airodump-ng $MONITOR | tee "$OUT"
  log "Scan complete. Results in $OUT"
}
