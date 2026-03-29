#!/bin/bash
# ==========================================================
# DarkBit Wi-Fi Pentesting Toolkit v3.1 (Modular Framework)
# "Invisible in the noise, inevitable in the system."
# ==========================================================

CONFIG="toolkit.conf"
LOGDIR="logs"
MODULEDIR="modules"
mkdir -p $LOGDIR $MODULEDIR

# Load config
if [ -f "$CONFIG" ]; then
  source $CONFIG
else
  echo "[*] No config found. Creating default..."
  cat > $CONFIG <<EOF
INTERFACE="wlan0"
MONITOR="wlan0mon"
WORDLIST="/usr/share/wordlists/rockyou.txt"
EOF
  source $CONFIG
fi

# Banner
clear
echo "=================================================="
echo "       DarkBit Wi-Fi Pentesting Toolkit v3.1      "
echo "=================================================="
echo "Interface: $INTERFACE | Monitor: $MONITOR"
echo "Wordlist : $WORDLIST"
echo "Modules  : $MODULEDIR/"
echo "Logs     : $LOGDIR/"
echo

# Logging helper
log() {
  echo "[$(date +%F-%H%M)] $1" | tee -a $LOGDIR/toolkit.log
}

# Load modules dynamically
MODULES=()
i=1
for mod in $MODULEDIR/*.sh; do
  [ -e "$mod" ] || continue
  source "$mod"
  MODULES+=("$mod")
  echo "[$i] $NAME - $DESCRIPTION"
  ((i++))
done

echo "[$i] Exit"
echo

# Menu loop
read -p "Choose option: " opt
if [ "$opt" -ge 1 ] && [ "$opt" -lt "$i" ]; then
  source "${MODULES[$((opt-1))]}"
  run
elif [ "$opt" -eq "$i" ]; then
  log "Exiting toolkit."
  exit 0
else
  echo "[!] Invalid option"
fi
