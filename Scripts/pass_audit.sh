#!/usr/bin/env bash
#
# Script Name: pass_audit.sh
# Description: Password policy auditor for Linux systems.
#              Checks /etc/login.defs, PAM configs, and shadow file for weak policies.
# Usage: ./pass_audit.sh
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

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Linux Password Policy Auditor v1.0            ║${NC}"
echo -e "${BLUE}║      Check password strength, expiry, and policies     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Password Expiry Policy
echo -e "${CYAN}[1] Password Expiry Policy (/etc/login.defs)${NC}"
if [[ -r /etc/login.defs ]]; then
    PASS_MAX=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
    PASS_MIN=$(grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')
    PASS_WARN=$(grep "^PASS_WARN_AGE" /etc/login.defs | awk '{print $2}')
    PASS_LEN=$(grep "^PASS_MIN_LEN" /etc/login.defs | awk '{print $2}')

    echo -e "    ${BLUE}Max Days: ${NC}${PASS_MAX:-Not set} $([ "${PASS_MAX:-99999}" -gt 90 ] && echo "${RED}(WARN: >90 days)${NC}" || echo "${GREEN}(OK)${NC}")"
    echo -e "    ${BLUE}Min Days: ${NC}${PASS_MIN:-Not set}"
    echo -e "    ${BLUE}Warn Age: ${NC}${PASS_WARN:-Not set}"
    echo -e "    ${BLUE}Min Length: ${NC}${PASS_LEN:-Not set} $([ "${PASS_LEN:-0}" -lt 8 ] && echo "${RED}(WARN: <8 chars)${NC}" || echo "${GREEN}(OK)${NC}")"
else
    echo -e "    ${YELLOW}[-] /etc/login.defs not readable${NC}"
fi
echo ""

# 2. Password Complexity (PAM)
echo -e "${CYAN}[2] Password Complexity (PAM Configuration)${NC}"
PAM_FILES="/etc/pam.d/common-password /etc/pam.d/system-auth /etc/pam.d/password-auth"
found_pam=false
for pam_file in $PAM_FILES; do
    if [[ -r "$pam_file" ]]; then
        found_pam=true
        echo -e "    ${GREEN}[+] Checking: ${pam_file}${NC}"
        if grep -q "pam_pwquality\|pam_cracklib\|pam_passwdqc" "$pam_file" 2>/dev/null; then
            echo -e "        ${GREEN}[+] Password complexity module found${NC}"
            grep "pam_pwquality\|pam_cracklib\|pam_passwdqc" "$pam_file" | sed 's/^/            /'
        else
            echo -e "        ${RED}[-] No password complexity module configured${NC}"
        fi
    fi
done
if [[ "$found_pam" == false ]]; then
    echo -e "    ${YELLOW}[-] No common PAM password files found${NC}"
fi
echo ""

# 3. User Password Status
echo -e "${CYAN}[3] User Password Status${NC}"
if [[ -r /etc/shadow ]]; then
    echo -e "    ${BLUE}Checking for accounts with empty passwords:${NC}"
    EMPTY_PASS=$(awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow 2>/dev/null)
    if [[ -n "$EMPTY_PASS" ]]; then
        echo -e "    ${RED}[!] Accounts with empty/locked passwords:${NC}"
        echo "$EMPTY_PASS" | sed 's/^/        /'
    else
        echo -e "    ${GREEN}[+] No accounts with empty passwords${NC}"
    fi

    echo -e "    ${BLUE}Checking for accounts with no password expiry:${NC}"
    NO_EXPIRY=$(awk -F: '($5 == -1 || $5 == 99999 || $5 == "") {print $1}' /etc/shadow 2>/dev/null)
    if [[ -n "$NO_EXPIRY" ]]; then
        echo -e "    ${YELLOW}[WARN] Accounts without password expiry:${NC}"
        echo "$NO_EXPIRY" | sed 's/^/        /'
    else
        echo -e "    ${GREEN}[+] All accounts have password expiry set${NC}"
    fi
else
    echo -e "    ${YELLOW}[-] /etc/shadow not readable (run as root for full audit)${NC}"
fi
echo ""

# 4. Password Hashing Algorithm
echo -e "${CYAN}[4] Password Hashing Algorithm${NC}"
if [[ -r /etc/shadow ]]; then
    HASH_TYPE=$(head -1 /etc/shadow | cut -d: -f2 | cut -c1-3)
    case "$HASH_TYPE" in
        '$1$')
            echo -e "    ${RED}[!] MD5 (weak) - Consider upgrading to SHA-512 or yescrypt${NC}"
            ;;
        '$5$')
            echo -e "    ${YELLOW}[WARN] SHA-256 - Acceptable, but SHA-512 is preferred${NC}"
            ;;
        '$6$')
            echo -e "    ${GREEN}[+] SHA-512 (strong)${NC}"
            ;;
        '$y$'|'$2b$'|'$2y$')
            echo -e "    ${GREEN}[+] yescrypt/bcrypt (strong)${NC}"
            ;;
        *)
            echo -e "    ${YELLOW}[?] Unknown or legacy hash format: ${HASH_TYPE}${NC}"
            ;;
    esac
else
    echo -e "    ${YELLOW}[-] /etc/shadow not readable${NC}"
fi
echo ""

# 5. Account Lockout Policy
echo -e "${CYAN}[5] Account Lockout Policy (PAM)${NC}"
found_lockout=false
for pam_file in $PAM_FILES; do
    if [[ -r "$pam_file" ]]; then
        if grep -q "pam_faillock\|pam_tally2" "$pam_file" 2>/dev/null; then
            found_lockout=true
            echo -e "    ${GREEN}[+] Account lockout module found in: ${pam_file}${NC}"
            grep "pam_faillock\|pam_tally2" "$pam_file" | sed 's/^/        /'
        fi
    fi
done
if [[ "$found_lockout" == false ]]; then
    echo -e "    ${RED}[!] No account lockout policy configured - brute-force risk${NC}"
fi
echo ""

# 6. Root Account
echo -e "${CYAN}[6] Root Account Security${NC}"
ROOT_HASH=$(grep "^root:" /etc/shadow 2>/dev/null | cut -d: -f2)
if [[ -z "$ROOT_HASH" || "$ROOT_HASH" == "!" || "$ROOT_HASH" == "*" ]]; then
    echo -e "    ${GREEN}[+] Root login is disabled or locked${NC}"
else
    echo -e "    ${RED}[!] Root account has a password set - consider disabling direct root login${NC}"
fi

ROOT_SHELL=$(grep "^root:" /etc/passwd 2>/dev/null | cut -d: -f7)
if [[ "$ROOT_SHELL" == "/usr/sbin/nologin" || "$ROOT_SHELL" == "/bin/false" ]]; then
    echo -e "    ${GREEN}[+] Root shell is disabled${NC}"
else
    echo -e "    ${YELLOW}[WARN] Root shell is ${ROOT_SHELL} - ensure it's necessary${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  Audit Summary                         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo -e "${BLUE}[*] Review RED items for critical issues${NC}"
echo -e "${BLUE}[*] Review YELLOW items for warnings${NC}"
echo -e "${BLUE}[*] Run this script regularly to monitor policy compliance${NC}"
