NAME="Generate Report"
DESCRIPTION="Compile recent logs into a summary report"

run() {
  REPORT="$LOGDIR/report-$(date +%F-%H%M).txt"
  log "Generating report $REPORT"
  {
    echo "========== DarkBit Wi-Fi Pentest Report =========="
    echo "Date: $(date)"
    echo
    echo "[*] Networks scanned:"
    tail -n 10 $LOGDIR/scan-*.log 2>/dev/null
    echo
    echo "[*] Crack attempts:"
    tail -n 10 $LOGDIR/crack-*.log 2>/dev/null
  } > $REPORT
  echo "[+] Report saved: $REPORT"
}
