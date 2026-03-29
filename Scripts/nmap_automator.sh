#!/bin/bash

# Simple Nmap Automation Wrapper
# Usage: ./nmap_automator.sh <IP_ADDRESS>

if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="nmap_scans_$TARGET"

mkdir -p "$OUTPUT_DIR"

echo "[*] Starting Fast Scan on $TARGET..."
nmap -T4 -F "$TARGET" -oG "$OUTPUT_DIR/fast_scan.txt"

echo "[*] Starting Detailed Scan on discovered ports..."
# Extracting open ports from fast scan
PORTS=$(grep -oP '\d+/open' "$OUTPUT_DIR/fast_scan.txt" | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')

if [ -z "$PORTS" ]; then
    echo "[-] No open ports found. Exiting."
    exit 0
fi

echo "[+] Open ports found: $PORTS"
nmap -T4 -sC -sV -p "$PORTS" "$TARGET" -oN "$OUTPUT_DIR/detailed_scan.txt"

echo "[SUCCESS] Scan complete. Results saved in $OUTPUT_DIR/"
