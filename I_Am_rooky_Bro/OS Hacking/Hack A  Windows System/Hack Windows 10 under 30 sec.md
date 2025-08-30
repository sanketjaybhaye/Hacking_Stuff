### Lab Notes – Windows 10 Local Account Password Reset (Offline) Scenario



* System: Windows 10 laptop (gaming machine)
* Account type: Local Administrator account
* Drive encryption:  Not enabled (no BitLocker)
* Problem: Forgot admin password
* Goal: Regain access



#### Key Concepts



* Local Accounts: Passwords stored in the Windows SAM (Security Accounts Manager) database.
* Microsoft Accounts: Cannot be reset offline in the same way, since verification is cloud-based.
* Encryption: If full-disk encryption (BitLocker) is enabled, offline password reset becomes impossible.



#### Method Overview



Booted from a Kali Linux Live USB in forensic mode.



Mounted the Windows drive.



1. Navigated to: /Windows/System32/config/
2. Enumerated accounts with: chntpw -l SAM
3. Selected the target user (Admin account).
4. Used chntpw to:
5. Unlock the account
6. Clear the password
7. Rebooted → Logged in with no password.
