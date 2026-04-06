# Contributing to Hacking_Stuff

Thanks for your interest in contributing to **Hacking_Stuff**! This repo is a curated collection of ethical hacking resources, and contributions help keep it fresh and useful for the community.

## 🚀 How to Contribute

### 1. Fork the Repository
Click the **Fork** button at the top right of the repo page to create your own copy.

### 2. Clone Your Fork
```bash
git clone https://github.com/YOUR_USERNAME/Hacking_Stuff.git
cd Hacking_Stuff
```

### 3. Create a Branch
Use a descriptive branch name:
```bash
git checkout -b add-nmap-cheatsheet
git checkout -b fix-typo-in-readme
git checkout -b add-api-security-checklist
```

### 4. Make Your Changes
Follow the guidelines below based on what you're adding.

---

## 📂 Contribution Guidelines by Section

### 🗂️ Cheat_Sheets
- Use Markdown format with clear headings
- Include command examples with expected output where relevant
- Add a brief description at the top explaining what the tool does
- Reference official documentation links
- Keep it concise — focus on commonly-used flags and options

**Example structure:**
```markdown
# Tool Name

## Description
Brief description of the tool and its purpose.

## Common Commands
| Command | Description |
|---------|-------------|
| `command --flag` | What it does |

## References
- [Official Docs](link)
```

### 🧑‍💻 Beginner_Guides
- Write in clear, beginner-friendly language
- Include step-by-step instructions
- Add screenshots or diagrams if helpful
- Mention any prerequisites (tools, knowledge)
- Include a "Further Reading" section with links

### ⚙️ Scripts
- Add a clear header comment explaining what the script does
- Include usage examples in comments or a README
- Use [ShellCheck](https://www.shellcheck.net/) for Bash scripts
- For Python scripts, follow PEP 8 style
- **Important:** Only include scripts for **authorized testing** and educational purposes
- Add a disclaimer if the script can be misused

**Python example header:**
```python
#!/usr/bin/env python3
"""
Script Name: port_scanner.py
Description: Simple TCP port scanner for educational purposes.
Usage: python3 port_scanner.py <target_ip>
Disclaimer: Only use on systems you own or have explicit permission to test.
"""
```

### 📝 CTF_Writeups
- Include the platform (HackTheBox, TryHackMe, VulnHub, etc.)
- Mention the machine/CTF name and difficulty
- Walk through your methodology step-by-step
- Explain **why** you took each step, not just **what** you did
- Redact any sensitive information (flags, IPs if required)

### ✅ Checklists
- Use checkbox format for actionable items
- Group related checks under subheadings
- Reference standards (OWASP, NIST, etc.) where applicable
- Keep items specific and testable

**Example:**
```markdown
## Authentication Testing
- [ ] Test for default credentials
- [ ] Check for brute-force protection
- [ ] Verify password complexity requirements
- [ ] Test for account lockout mechanisms
```

### 🛠️ Configs
- Include comments explaining each setting
- Mention which distros/versions the config was tested on
- Provide a backup or default version if applicable

### 👾 Vulnerable_Code
- Clearly label the vulnerability type (SQLi, XSS, RCE, etc.)
- Include both the **vulnerable** and **patched** versions
- Explain the exploit and the fix
- Add references to OWASP or CVEs where relevant

---

## 📝 Commit Message Conventions

Use clear, descriptive commit messages:
```
feat: add Nmap cheat sheet
fix: correct typo in Wi-Fi guide
docs: update contributing guidelines
script: add subdomain enumeration tool
checklist: add API security testing checklist
```

Prefixes:
- `feat:` — New content or feature
- `fix:` — Bug fixes or corrections
- `docs:` — Documentation changes
- `script:` — New or updated scripts
- `checklist:` — New or updated checklists
- `refactor:` — Code restructuring without behavior change

---

## ⚖️ Code of Conduct

- **Be respectful.** Treat all contributors and users with kindness.
- **Stay ethical.** This repo is for **educational purposes and authorized testing only**.
- **No malicious content.** Do not submit scripts, exploits, or guides intended for illegal activities.
- **Give credit.** If you reference or adapt someone else's work, cite the source.

---

## 🐛 Reporting Issues

Found a typo, broken link, or outdated info? Open an [issue](https://github.com/sanketjaybhaye/Hacking_Stuff/issues) with:
- A clear title
- A description of the problem
- Steps to reproduce (if applicable)
- Suggested fix (if you have one)

---

## 💡 Feature Requests

Have an idea for a new section, cheat sheet, or script? Open an [issue](https://github.com/sanketjaybhaye/Hacking_Stuff/issues) with the `enhancement` label and describe:
- What you'd like to see
- Why it would be useful
- Any references or examples

---

## 🎓 Learning Resources

New to ethical hacking? Check out these resources:
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [HackTheBox](https://www.hackthebox.com/)
- [TryHackMe](https://tryhackme.com/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)

---

## 🙏Thank You

Every contribution, no matter how small, helps make **Hacking_Stuff** better for everyone. Thanks for being part of the community!

— Sanket Jaybhaye
