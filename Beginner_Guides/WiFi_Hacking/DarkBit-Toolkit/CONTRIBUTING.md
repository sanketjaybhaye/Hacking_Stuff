# Contributing to DarkBit Wi-Fi Pentesting Toolkit

First off — thanks for taking the time to contribute! ⚡  
This project is meant to stay **clean, professional, and ethical**.

---

## 🚀 How to Contribute
1. **Fork** this repository and clone your fork
2. Create a new branch for your feature:  
   ```bash
   git checkout -b feature/my-new-module
   ```
3. Add your module under `/modules/`:
   - File name should be descriptive: `wps.sh`, `evil_twin.sh`, etc.
   - Must define at least these three variables:  
     ```bash
     NAME="Module Name"
     DESCRIPTION="Short explanation"
     run() {
       # your code
     }
     ```
4. Test your module in a **lab environment only**
5. Commit your changes:  
   ```bash
   git commit -m "Added new module: my feature"
   ```
6. Push to your branch:  
   ```bash
   git push origin feature/my-new-module
   ```
7. Open a **Pull Request** for review

---

## 📋 Code Style
- Keep modules in **pure Bash**
- Use **clear, descriptive variable names**
- Add minimal inline comments for readability
- Always log actions with the built-in logger:  
  ```bash
  log "Description of action performed"
  ```

---

## 🔐 Ethics Reminder
- **No black-hat code** — this toolkit is for education and **authorized pentests only**
- Any module must be safe for **lab testing**
- If unsure, mark your module as a **placeholder** until it’s validated

---

## 🛠 Ideas for Contribution
- WPA3 testing (lab mode)
- WPS audit module
- Evil Twin simulation (lab mode)
- Automated reporting (HTML/PDF export)
- Rogue AP / deauth detection
- Wordlist manager

---

⚡ Together, let’s grow **DarkBit** into a professional, extensible Wi-Fi pentest toolkit.
