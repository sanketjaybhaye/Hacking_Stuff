#!/usr/bin/env bash
# juice_reset.sh - reset Juice Shop DB and uploads (assumes ~/juice-shop data path)
set -e
APP_DIR="$HOME/juice-shop"
echo "[*] Stopping any running juice-shop node processes..."
pkill -f "node.*juice-shop" || true
echo "[*] Removing DB and uploads if present..."
rm -f "$APP_DIR/data/owasp-juice-shop.db" || true
rm -rf "$APP_DIR/data/uploads" || true
echo "[*] Done. Start the app with: HOST=127.0.0.1 PORT=3000 npm start (from $APP_DIR)"
