#!/usr/bin/env bash
#
# Script Name: linprivcheck.sh
# Description: Lightweight Linux privilege escalation checklist.
#              Automates common checks for SUID, sudo, cron, capabilities, and more.
# Usage: ./linprivcheck.sh
# Disclaimer: For educational purposes and authorized testing only.
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Linux Privilege Escalation Checklist v1.0        ║${NC}"
echo -e "${BLUE}║              Quick Recon & Enumeration                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. System Information
echo -e "${CYAN}[1] System Information${NC}"
echo -e "${BLUE}    Kernel: ${NC}$(uname -r)"
echo -e "${BLUE}    OS: ${NC}$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'Unknown')"
echo -e "${BLUE}    Hostname: ${NC}$(hostname)"
echo -e "${BLUE}    Current User: ${NC}$(whoami) (UID: $(id -u))"
echo ""

# 2. SUID Binaries
echo -e "${CYAN}[2] SUID Binaries${NC}"
SUID_FILES=$(find / -perm -4000 -type f 2>/dev/null | head -20)
if [[ -n "$SUID_FILES" ]]; then
    while IFS= read -r file; do
        echo -e "    ${GREEN}[+] ${NC}${file}"
    done <<< "$SUID_FILES"
else
    echo -e "    ${YELLOW}[-] No SUID binaries found${NC}"
fi
echo ""

# 3. SGID Binaries
echo -e "${CYAN}[3] SGID Binaries${NC}"
SGID_FILES=$(find / -perm -2000 -type f 2>/dev/null | head -10)
if [[ -n "$SGID_FILES" ]]; then
    while IFS= read -r file; do
        echo -e "    ${GREEN}[+] ${NC}${file}"
    done <<< "$SGID_FILES"
else
    echo -e "    ${YELLOW}[-] No SGID binaries found${NC}"
fi
echo ""

# 4. Sudo Permissions
echo -e "${CYAN}[4] Sudo Permissions${NC}"
if command -v sudo &>/dev/null; then
    SUDO_OUT=$(sudo -l 2>/dev/null || echo "No sudo access or password required")
    if [[ "$SUDO_OUT" != *"password"* ]]; then
        echo -e "    ${GREEN}[+] Sudo permissions found:${NC}"
        echo "$SUDO_OUT" | grep -v "^$" | sed 's/^/    /'
    else
        echo -e "    ${YELLOW}[-] ${SUDO_OUT}${NC}"
    fi
else
    echo -e "    ${YELLOW}[-] sudo not installed${NC}"
fi
echo ""

# 5. Cron Jobs
echo -e "${CYAN}[5] Cron Jobs${NC}"
if [[ -r /etc/crontab ]]; then
    echo -e "    ${GREEN}[+] /etc/crontab contents:${NC}"
    cat /etc/crontab | sed 's/^/    /'
else
    echo -e "    ${YELLOW}[-] /etc/crontab not readable${NC}"
fi

# User crontabs
USER_CRON=$(crontab -l 2>/dev/null || echo "")
if [[ -n "$USER_CRON" ]]; then
    echo -e "    ${GREEN}[+] User crontab:${NC}"
    echo "$USER_CRON" | sed 's/^/    /'
fi
echo ""

# 6. Capabilities
echo -e "${CYAN}[6] File Capabilities${NC}"
if command -v getcap &>/dev/null; then
    CAPS=$(getcap -r / 2>/dev/null | head -10)
    if [[ -n "$CAPS" ]]; then
        echo -e "    ${GREEN}[+] Capabilities found:${NC}"
        echo "$CAPS" | sed 's/^/    /'
    else
        echo -e "    ${YELLOW}[-] No special capabilities found${NC}"
    fi
else
    echo -e "    ${YELLOW}[-] getcap not available${NC}"
fi
echo ""

# 7. Writable Files
echo -e "${CYAN}[7] World-Writable Files (common targets)${NC}"
WRITABLE=$(find /etc /opt /var /tmp -writable -type f 2>/dev/null | grep -v "/proc\|/sys" | head -10)
if [[ -n "$WRITABLE" ]]; then
    echo -e "    ${GREEN}[+] Writable files:${NC}"
    echo "$WRITABLE" | sed 's/^/    /'
else
    echo -e "    ${YELLOW}[-] No obvious writable files in /etc, /opt, /var, /tmp${NC}"
fi
echo ""

# 8. SSH Keys
echo -e "${CYAN}[8] SSH Keys${NC}"
if [[ -d ~/.ssh ]]; then
    KEYS=$(ls -la ~/.ssh/ 2>/dev/null)
    echo -e "    ${GREEN}[+] SSH directory contents:${NC}"
    echo "$KEYS" | sed 's/^/    /'
else
    echo -e "    ${YELLOW}[-] No .ssh directory${NC}"
fi
echo ""

# 9. Network Connections
echo -e "${CYAN}[9] Listening Services${NC}"
if command -v ss &>/dev/null; then
    ss -tulpn 2>/dev/null | head -10 | sed 's/^/    /'
elif command -v netstat &>/dev/null; then
    netstat -tulpn 2>/dev/null | head -10 | sed 's/^/    /'
else
    echo -e "    ${YELLOW}[-] Neither ss nor netstat available${NC}"
fi
echo ""

# 10. Installed Languages/Tools
echo -e "${CYAN}[10] Available Interpreters & Tools${NC}"
for cmd in python python3 perl ruby php gcc make wget curl nc nmap; do
    if command -v $cmd &>/dev/null; then
        echo -e "    ${GREEN}[+] ${NC}${cmd}: $(which $cmd)"
    fi
done
echo ""

echo -e "${BLUE}[*] Checklist complete. Review findings for privilege escalation opportunities.${NC}"
echo -e "${BLUE}[*] For deeper analysis, consider running LinPEAS or linux-smart-enumeration.${NC}"
