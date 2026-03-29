NAME="Defensive Audit"
DESCRIPTION="Check router/AP for WPA3, PMF, WPS support"
run() {
  log "Running defensive audit..."
  iw list | egrep -i "SAE|PMF|WPA3|WEP|WPS"
}
