#!/usr/bin/env bash
#
# Script Name: subdomain_enum.sh
# Description: Multi-source subdomain enumeration tool for authorized reconnaissance.
# Usage: ./subdomain_enum.sh <domain> [output_file]
# Disclaimer: Only use on domains you own or have explicit permission to test.
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if domain is provided
if [[ $# -lt 1 ]]; then
    echo -e "${RED}[!] Usage: $0 <domain> [output_file]${NC}"
    echo -e "${YELLOW}[i] Example: $0 example.com results.txt${NC}"
    exit 1
fi

DOMAIN="$1"
OUTPUT_FILE="${2:-${DOMAIN}_subdomains.txt}"
TEMP_DIR=$(mktemp -d)

echo -e "${BLUE}[*] Starting subdomain enumeration for: ${DOMAIN}${NC}"
echo -e "${BLUE}[*] Output file: ${OUTPUT_FILE}${NC}"
echo -e "${BLUE}[*] Timestamp: $(date)${NC}"
echo "========================================"

# Initialize empty results file
> "$TEMP_DIR/all_subdomains.txt"

# Source 1: crt.sh (Certificate Transparency logs)
echo -e "${GREEN}[+] Querying crt.sh...${NC}"
curl -s "https://crt.sh/?q=%.${DOMAIN}&output=json" 2>/dev/null | \
    jq -r '.[].name_value' 2>/dev/null | \
    sed 's/\*\.//g' | \
    sort -u >> "$TEMP_DIR/all_subdomains.txt" || echo -e "${YELLOW}[!] crt.sh query failed${NC}"

# Source 2: Sublist3r-style passive sources via RapidAPI alternatives
# Using AlienVault OTX
echo -e "${GREEN}[+] Querying AlienVault OTX...${NC}"
curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/${DOMAIN}/passive_dns" 2>/dev/null | \
    jq -r '.passive_dns[].hostname' 2>/dev/null | \
    grep "\.${DOMAIN}$" | \
    sort -u >> "$TEMP_DIR/all_subdomains.txt" || echo -e "${YELLOW}[!] AlienVault OTX query failed${NC}"

# Source 3: ThreatCrowd
echo -e "${GREEN}[+] Querying ThreatCrowd...${NC}"
curl -s "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=${DOMAIN}" 2>/dev/null | \
    jq -r '.subdomains[]' 2>/dev/null | \
    sort -u >> "$TEMP_DIR/all_subdomains.txt" || echo -e "${YELLOW}[!] ThreatCrowd query failed${NC}"

# Source 4: Hackertarget
echo -e "${GREEN}[+] Querying Hackertarget...${NC}"
curl -s "https://api.hackertarget.com/hostsearch/?q=${DOMAIN}" 2>/dev/null | \
    cut -d',' -f1 | \
    grep "\.${DOMAIN}$" | \
    sort -u >> "$TEMP_DIR/all_subdomains.txt" || echo -e "${YELLOW}[!] Hackertarget query failed${NC}"

# Deduplicate and clean results
echo -e "${BLUE}[*] Deduplicating results...${NC}"
grep "\.${DOMAIN}$" "$TEMP_DIR/all_subdomains.txt" | \
    sed 's/^\.//' | \
    sort -u | \
    grep -v '^$' > "$OUTPUT_FILE" 2>/dev/null || true

# Count results
RESULT_COUNT=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo "0")

echo "========================================"
echo -e "${GREEN}[+] Enumeration complete!${NC}"
echo -e "${GREEN}[+] Found ${RESULT_COUNT} unique subdomains${NC}"
echo -e "${GREEN}[+] Results saved to: ${OUTPUT_FILE}${NC}"
echo "========================================"

# Display top 10 results
if [[ "$RESULT_COUNT" -gt 0 ]]; then
    echo -e "${YELLOW}[i] Preview (first 10):${NC}"
    head -10 "$OUTPUT_FILE" | nl
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "${BLUE}[*] Done.${NC}"
