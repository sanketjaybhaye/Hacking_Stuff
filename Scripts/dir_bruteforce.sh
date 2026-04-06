#!/usr/bin/env bash
#
# Script Name: dir_bruteforce.sh
# Description: Lightweight directory and file brute-forcer using curl.
#              Supports custom wordlists, extensions, and HTTP methods.
# Usage: ./dir_bruteforce.sh <url> [wordlist] [extensions]
# Example:
#     ./dir_bruteforce.sh https://example.com
#     ./dir_bruteforce.sh https://example.com /usr/share/wordlists/dirb/common.txt
#     ./dir_bruteforce.sh https://example.com wordlist.txt "php,html,txt"
# Disclaimer: Only use on systems you own or have explicit permission to test.
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
URL="${1:-}"
WORDLIST="${2:-/usr/share/wordlists/dirb/common.txt}"
EXTENSIONS="${3:-}"
THREADS=20
TIMEOUT=5
STATUS_CODE=0
METHOD="GET"

# Check if URL is provided
if [[ -z "$URL" ]]; then
    echo -e "${RED}[!] Usage: $0 <url> [wordlist] [extensions]${NC}"
    echo -e "${YELLOW}[i] Example: $0 https://example.com${NC}"
    echo -e "${YELLOW}[i] Example: $0 https://example.com wordlist.txt \"php,html\"${NC}"
    exit 1
fi

# Ensure URL has protocol
if [[ ! "$URL" =~ ^https?:// ]]; then
    URL="https://${URL}"
fi

# Remove trailing slash
URL="${URL%/}"

# Check if wordlist exists
if [[ ! -f "$WORDLIST" ]]; then
    echo -e "${RED}[!] Wordlist not found: ${WORDLIST}${NC}"
    echo -e "${YELLOW}[i] Try installing dirb: apt install dirb${NC}"
    exit 1
fi

echo -e "${BLUE}[*] Directory Bruteforce Scanner${NC}"
echo -e "${BLUE}[*] Target: ${URL}${NC}"
echo -e "${BLUE}[*] Wordlist: ${WORDLIST}${NC}"
echo -e "${BLUE}[*] Extensions: ${EXTENSIONS:-none}${NC}"
echo -e "${BLUE}[*] Threads: ${THREADS} | Timeout: ${TIMEOUT}s${NC}"
echo -e "${BLUE}[*] Method: ${METHOD}${NC}"
echo "========================================"

# Function to scan a single path
scan_path() {
    local path="$1"
    local full_url="${URL}/${path}"

    # Try with and without extensions
    local paths_to_try=("$path")

    if [[ -n "$EXTENSIONS" ]]; then
        IFS=',' read -ra EXTS <<< "$EXTENSIONS"
        for ext in "${EXTS[@]}"; do
            paths_to_try+=("${path}.${ext}")
        done
    fi

    for try_path in "${paths_to_try[@]}"; do
        local response
        response=$(curl -s -o /dev/null -w "%{http_code}" \
            --max-time "$TIMEOUT" \
            -L \
            "${URL}/${try_path}" 2>/dev/null) || continue

        STATUS_CODE="$response"

        # Filter out common non-interesting codes (404, 403 in some cases)
        if [[ "$STATUS_CODE" =~ ^(200|204|301|302|307|403|500)$ ]]; then
            local color="$GREEN"
            if [[ "$STATUS_CODE" == "403" ]]; then
                color="$YELLOW"
            elif [[ "$STATUS_CODE" == "500" ]]; then
                color="$RED"
            fi

            echo -e "${color}[+] ${STATUS_CODE} ${try_path}${NC}"
        fi
    done
}

export -f scan_path
export URL EXTENSIONS TIMEOUT STATUS_CODE

# Run scans in parallel
FOUND=0
while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    scan_path "$line" &

    # Limit concurrent jobs
    if (( $(jobs -r | wc -l) >= THREADS )); then
        wait -n
    fi
done < "$WORDLIST"

# Wait for remaining jobs
wait

echo "========================================"
echo -e "${GREEN}[+] Scan complete.${NC}"
echo -e "${BLUE}[*] Finished at $(date)${NC}"
