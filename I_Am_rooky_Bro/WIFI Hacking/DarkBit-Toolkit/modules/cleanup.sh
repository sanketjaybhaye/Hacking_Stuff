NAME="Cleanup"
DESCRIPTION="Restore network manager & interfaces"
run() {
  log "Restoring network..."
  service NetworkManager restart
  ip link set $INTERFACE up
  log "Cleanup complete"
}
