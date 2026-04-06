#!/usr/bin/env bash
#
# Script Name: sub_takeover.sh
# Description: Subdomain takeover vulnerability scanner.
#              Checks if subdomains point to unclaimed cloud services.
# Usage: ./sub_takeover.sh <domain> [subdomain_file]
# Example: ./sub_takeover.sh example.com subs.txt
# Disclaimer: For authorized security assessments only.
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check arguments
if [[ $# -lt 1 ]]; then
    echo -e "${RED}[!] Usage: $0 <domain> [subdomain_file]${NC}"
    echo -e "${YELLOW}[i] Example: $0 example.com subs.txt${NC}"
    exit 1
fi

DOMAIN="$1"
SUB_FILE="${2:-}"

# Known takeover signatures
declare -A TAKEOVER_SIGS
TAKEOVER_SIGS=(
    ["AWS S3"]="NoSuchBucket|The specified bucket does not exist"
    ["GitHub Pages"]="There isn't a GitHub Pages site here"
    ["Heroku"]="No such app|herokucdn.com/error/no-such-app"
    ["Bitbucket"]="Repository not found"
    ["Azure"]="404 Web Site not found"
    ["Shopify"]="Sorry, this shop is currently unavailable"
    ["Tumblr"]="There's nothing here"
    ["Wordpress"]="Do you want to register"
    ["Campaign Monitor"]="Monthly email newsletter"
    ["Ghost"]="The thing you were looking for is no longer here"
    ["Pantheon"]="404 Not Found"
    ["Surge"]="project not found"
    ["Help Scout"]="No help center here"
    ["Zendesk"]="Help Center Closed"
    ["Uservoice"]="This UserVoice subdomain is currently available"
    ["Jetbrains"]="is not a registered InCloud YouTrack"
    ["Smartling"]="Domain is not configured"
    ["Pingdom"]="Public Report Not Found"
    ["Tilda"]="Domain has been assigned"
    ["AnnounceKit"]="Company not found"
    ["WantMySite"]="404 error"
)

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Subdomain Takeover Scanner v1.0                  ║${NC}"
echo -e "${BLUE}║   Check for unclaimed cloud service subdomains        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get subdomains
if [[ -n "$SUB_FILE" && -f "$SUB_FILE" ]]; then
    SUBDOMAINS=$(cat "$SUB_FILE")
else
    echo -e "${BLUE}[*] No subdomain file provided. Fetching from crt.sh...${NC}"
    SUBDOMAINS=$(curl -s "https://crt.sh/?q=%.${DOMAIN}&output=json" 2>/dev/null | \
        jq -r '.[].name_value' 2>/dev/null | \
        sed 's/\*\.//g' | \
        sort -u | \
        grep "\.${DOMAIN}$" || echo "")
fi

if [[ -z "$SUBDOMAINS" ]]; then
    echo -e "${RED}[!] No subdomains found for ${DOMAIN}${NC}"
    exit 1
fi

SUB_COUNT=$(echo "$SUBDOMAINS" | wc -l)
echo -e "${BLUE}[*] Scanning ${SUB_COUNT} subdomains for takeover vulnerabilities...${NC}"
echo ""

VULN_COUNT=0

while IFS= read -r sub; do
    [[ -z "$sub" ]] && continue

    # Resolve subdomain
    IP=$(dig +short "$sub" 2>/dev/null | head -1)
    if [[ -z "$IP" ]]; then
        continue
    fi

    # Check HTTP response
    RESPONSE=$(curl -sL --max-time 5 "http://${sub}" 2>/dev/null || echo "")
    HTTPS_RESPONSE=$(curl -sLk --max-time 5 "https://${sub}" 2>/dev/null || echo "")
    COMBINED="${RESPONSE} ${HTTPS_RESPONSE}"

    # Check against known signatures
    for service in "${!TAKEOVER_SIGS[@]}"; do
        PATTERN="${TAKEOVER_SIGS[$service]}"
        if echo "$COMBINED" | grep -qi "$PATTERN"; then
            echo -e "${GREEN}[VULNERABLE] ${NC}${sub} → ${CYAN}${service}${NC}"
            echo -e "    ${YELLOW}Pattern matched: ${PATTERN}${NC}"
            VULN_COUNT=$((VULN_COUNT + 1))
            break
        fi
    done

done <<< "$SUBDOMAINS"

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  Scan Results                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"

if [[ $VULN_COUNT -gt 0 ]]; then
    echo -e "${GREEN}[+] Found ${VULN_COUNT} potentially vulnerable subdomain(s)${NC}"
    echo -e "${YELLOW}[i] Verify manually before claiming${NC}"
else
    echo -e "${GREEN}[+] No obvious takeover vulnerabilities found${NC}"
fi

echo -e "${BLUE}[*] Scan complete.${NC}"
