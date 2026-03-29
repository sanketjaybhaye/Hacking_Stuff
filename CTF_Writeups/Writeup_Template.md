# 🏆 [Machine Name] - [Platform] Writeup

**Platform:** HackTheBox / TryHackMe / VulnHub  
**Difficulty:** Easy / Medium / Hard  
**Date Completed:** YYYY-MM-DD  

---

## 🔍 1. Reconnaissance & Enumeration

### Nmap Scan
```bash
nmap -sC -sV -p- <IP>
```
*Port findings and thoughts:*
- **Port 21 (FTP):** Anonymous login allowed?
- **Port 80 (HTTP):** Web server running, time to run Gobuster.

### Web Discovery
```bash
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
```
*Interesting directories found:*


## 🔓 2. Initial Foothold

*Detail how you got your first shell (e.g., exploiting a vulnerable plugin, finding credentials, etc.).*

```bash
# Payload or exploit command used
```

## 🪜 3. Privilege Escalation

*Detail the steps to move from a standard user to `root` or `SYSTEM`.*

### User Flag
```bash
cat /home/user/user.txt
# Flag: HTB{...}
```

### Path to Root
*Found a SUID binary? A misconfigured cron job? Kernel exploit? Explain it.*

### Root Flag
```bash
cat /root/root.txt
# Flag: HTB{...}
```

## 🧠 Lessons Learned
- Describe the key takeaways from this machine.
- What new technique did you learn?
