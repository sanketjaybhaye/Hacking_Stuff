# Social Engineering Engagement Checklist

Methodology for authorized social engineering assessments (phishing, vishing, physical intrusion).

**⚠️ Legal Notice:** Social engineering engagements require explicit written authorization. Ensure scope, rules of engagement, and get-out-of-jail-free cards are documented before starting.

---

## Phase 1: Pre-Engagement

### Legal & Scope
- [ ] Signed authorization from client
- [ ] Defined scope (targets, methods, timeframe)
- [ ] Get-out-of-jail-free card (physical/digital)
- [ ] Emergency contact list (client security, legal, HR)
- [ ] Data handling agreement (what to do with captured credentials)

### Intelligence Gathering (OSINT)
- [ ] **Corporate Information:**
  - [ ] Company website, about page, leadership bios
  - [ ] LinkedIn employee lists (titles, departments)
  - [ ] Press releases, job postings (tech stack clues)
  - [ ] Social media presence (Twitter, Facebook, Instagram)
- [ ] **Email Format Discovery:**
  - [ ] Guess patterns: `first.last@`, `flast@`, `firstl@`
  - [ ] Verify with tools: Hunter.io, Snov.io, VoilaNorbert
  - [ ] Cross-reference with leaked databases (HaveIBeenPwned)
- [ ] **Technical Infrastructure:**
  - [ ] Domain registration info (WHOIS)
  - [ ] DNS records (MX, SPF, DKIM, DMARC)
  - [ ] Technology stack (BuiltWith, Wappalyzer)
  - [ ] VPN/remote access solutions in use

### Target Profiling
- [ ] Identify high-value targets:
  - [ ] C-level executives
  - [ ] HR/Recruiting (credential resets)
  - [ ] IT/Security (access control)
  - [ ] Finance (wire transfers)
  - [ ] Reception/Admin (physical access)
- [ ] Build psychological profiles:
  - [ ] Interests (from social media)
  - [ ] Communication style
  - [ ] Pain points (complaints on social media)

---

## Phase 2: Phishing Campaign

### Email Phishing
- [ ] **Infrastructure Setup:**
  - [ ] Register lookalike domains (`examp1e.com`, `example-support.com`)
  - [ ] Configure SMTP server (Postfix, SendGrid, Mailgun)
  - [ ] Set up landing pages (clone login portals)
  - [ ] SSL certificates for landing pages (Let's Encrypt)
- [ ] **Payload Development:**
  - [ ] Credential harvesting pages (O365, GSuite, VPN)
  - [ ] Malicious document macros (if in scope)
  - [ ] HTA/VBS files for code execution
  - [ ] QR code phishing (quishing)
- [ ] **Email Crafting:**
  - [ ] Urgent/time-sensitive language
  - [ ] Spoofed sender names (IT Support, HR, CEO)
  - [ ] Professional formatting (logos, signatures)
  - [ ] Link shortening to hide destinations
- [ ] **Evasion Techniques:**
  - [ ] Bypass spam filters (text-only, image-based)
  - [ ] Avoid known malicious keywords
  - [ ] Use legitimate email services (Gmail, Outlook.com)
  - [ ] Rotate sending IPs/domains

### Spear Phishing
- [ ] Highly targeted emails (1-5 recipients)
- [ ] Personalized content (reference recent events)
- [ ] Trusted sender impersonation (colleague, vendor)
- [ ] Custom landing pages matching corporate branding

### Whaling
- [ ] Target C-level executives
- [ ] CEO fraud (fake wire transfer requests)
- [ ] Legal/regulatory impersonation
- [ ] Highly personalized, low volume

### Metrics to Track
- [ ] Open rate
- [ ] Click rate
- [ ] Credential submission rate
- [ ] Payload execution rate
- [ ] Reporting rate (users who report to IT)

---

## Phase 3: Vishing (Voice Phishing)

### Pre-call Preparation
- [ ] Build credible backstory
- [ ] Prepare spoofed caller ID
- [ ] Script common objections/responses
- [ ] Have technical details ready (employee ID, department)

### Common Vishing Scenarios
- [ ] **IT Support Impersonation:**
  - "Hi, this is IT. We're updating passwords. What's yours?"
  - "Your account is locked. Let me reset it."
- [ ] **Executive Impersonation:**
  - "This is the CEO. I need you to wire money urgently."
  - "I'm in a meeting. Send me the credentials now."
- [ ] **Vendor Impersonation:**
  - "This is Microsoft support. Your license is expiring."
  - "We're from your ISP. There's a network issue."
- [ ] **Survey/Feedback:**
  - "We're conducting a security audit. Can you verify your login?"

### Information to Extract
- [ ] Passwords/PINs
- [ ] Security questions/answers
- [ ] Internal system names/URLs
- [ ] Employee IDs/badge numbers
- [ ] Network topology details

### Tools
- [ ] **Call Spoofing:** SpoofCard, Twilio
- [ ] **Recording:** Audacity, GarageBand
- [ ] **VoIP:** Asterisk, Zoiper

---

## Phase 4: Physical Intrusion

### Reconnaissance
- [ ] **Site Visit (Passive):**
  - [ ] Observe employee arrival/departure times
  - [ ] Identify security guards, cameras, badge readers
  - [ ] Note tailgating opportunities
  - [ ] Map parking lots, entrances, exits
- [ ] **Dumpster Diving:**
  - [ ] Look for organizational charts
  - [ ] Passwords on sticky notes
  - [ ] Discarded hardware (USB drives, hard drives)
  - [ ] Internal memos, policy documents
- [ ] **Social Media Geolocation:**
  - [ ] Employee posts from office (badge photos, desk setups)
  - [ ] Check-in locations
  - [ ] Photos of internal spaces

### Intrusion Techniques
- [ ] **Tailgating/Piggybacking:**
  - Hold door for employees with hands full
  - Follow closely behind authorized personnel
- [ ] **Badge Cloning:**
  - Use Proxmark3 to clone RFID badges
  - Purchase clone badges online
- [ ] **Impersonation:**
  - IT technician (with toolkit)
  - Delivery person (uniform, packages)
  - Contractor/vendor (clipboard, confidence)
  - New employee (confused, need help)
- [ ] **Shoulder Surfing:**
  - Observe passwords being typed
  - Use binoculars/cameras from distance
  - Install keyloggers (if in scope)

### Physical Payloads
- [ ] **USB Drops:**
  - Labelled "Confidential Salary Data"
  - Auto-execute payloads (Rubber Ducky, Bash Bunny)
  - Track which machines plug them in
- [ ] **Rogue Access Points:**
  - Plant wireless APs in lobby/conference rooms
  - Capture wireless handshakes
  - Man-in-the-middle attacks
- [ ] **Keyloggers:**
  - Hardware keyloggers on unattended PCs
  - Software keyloggers via USB drops

---

## Phase 5: Post-Engagement

### Data Handling
- [ ] Securely store all captured credentials
- [ ] Document all successful intrusions
- [ ] Preserve evidence (screenshots, recordings)
- [ ] Delete data after client confirms receipt

### Reporting
- [ ] **Executive Summary:**
  - Overall success rate
  - Critical findings
  - Business impact
- [ ] **Detailed Findings:**
  - Each attack vector used
  - Success/failure rates
  - User behavior analysis
- [ ] **Recommendations:**
  - Security awareness training topics
  - Technical controls (MFA, email filtering)
  - Physical security improvements
  - Policy updates

### Remediation Validation
- [ ] Re-test after remediation
- [ ] Verify training effectiveness
- [ ] Confirm technical controls are in place

---

## Psychological Principles

### Influence Tactics (Cialdini)
- [ ] **Reciprocity:** Give something small, ask for something big
- [ ] **Scarcity:** "Offer expires in 1 hour"
- [ ] **Authority:** Impersonate IT, law enforcement, executives
- [ ] **Consistency:** Get small commitment, escalate to big one
- [ ] **Liking:** Build rapport, find common ground
- [ ] **Social Proof:** "Everyone else has already updated their password"
- [ ] **Urgency:** "Act now or your account will be locked"

### Pretexting Tips
- [ ] Build a believable backstory
- [ ] Research target thoroughly
- [ ] Practice your script
- [ ] Stay calm under pressure
- [ ] Have escape routes (excuses to end conversation)

---

## Tools Summary

| Tool | Purpose | URL |
|------|---------|-----|
| GoPhish | Phishing campaign framework | getgophish.com |
| Evilginx2 | MFA phishing proxy | github.com/kgretzky/evilginx2 |
| SpoofCard | Caller ID spoofing | spoofcard.com |
| Proxmark3 | RFID badge cloning | proxmark.org |
| Rubber Ducky | USB keystroke injection | hakshop.com |
| Social Engineer Toolkit | All-in-one SE framework | github.com/trustedsec/social-engineer-toolkit |
| Hunter.io | Email format discovery | hunter.io |
| TheHarvester | OSINT email gathering | github.com/laramies/theHarvester |

---

## Legal & Ethical Considerations

- **Always have written authorization** before starting
- **Stay within scope** — don't target out-of-scope employees
- **Respect privacy** — don't access personal data unnecessarily
- **Report immediately** if you accidentally breach scope
- **Destroy all data** after engagement concludes
- **Never use techniques** for illegal purposes

---

*Last updated: 2026-04-06*
