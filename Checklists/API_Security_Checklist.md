# API Security Testing Checklist

Based on **OWASP API Security Top 10 (2023)**. Use this checklist during authorized API penetration tests.

---

## API01:2023 - Broken Object Level Authorization

**Risk:** High — attackers access other users' data via ID manipulation.

### Testing Steps
- [ ] Identify all endpoints that accept object IDs (user_id, order_id, etc.)
- [ ] Test for **IDOR** (Insecure Direct Object Reference):
  - [ ] Change `GET /api/users/123` to `GET /api/users/124`
  - [ ] Try sequential IDs, UUIDs, and other formats
- [ ] Test with different user roles (user → admin, user → another user)
- [ ] Check if authorization is enforced server-side (not just client-side)
- [ ] Verify horizontal access control (same role, different users)
- [ ] Verify vertical access control (different roles)

### Tools
- Burp Suite (Authorize extension)
- Postman
- Custom scripts

### Remediation
- Implement server-side authorization checks for every request
- Use unpredictable resource IDs (UUIDs instead of sequential integers)
- Apply least-privilege access controls

---

## API02:2023 - Broken Authentication

**Risk:** Critical — attackers compromise user accounts or API keys.

### Testing Steps
- [ ] Test for weak password policies:
  - [ ] Minimum length < 8 characters
  - [ ] No complexity requirements
  - [ ] No account lockout after failed attempts
- [ ] Check for **credential stuffing**:
  - [ ] Test common passwords against login endpoint
  - [ ] Use leaked credential databases
- [ ] Test for **brute-force protection**:
  - [ ] No rate limiting on login
  - [ ] No CAPTCHA after failed attempts
- [ ] Check for **JWT issues**:
  - [ ] Algorithm set to `none` (alg: none attack)
  - [ ] Weak signing keys
  - [ ] No expiration (`exp` claim)
  - [ ] Token reuse after logout
- [ ] Test for **API key exposure**:
  - [ ] Keys in URLs, logs, or client-side code
  - [ ] Keys without rotation or expiration
- [ ] Check for **session management**:
  - [ ] Sessions don't expire
  - [ ] No secure/HttpOnly flags on cookies

### Tools
- Burp Suite Intruder
- Hydra
- John the Ripper
- jwt.io (for JWT analysis)

### Remediation
- Enforce strong password policies
- Implement rate limiting and account lockout
- Use short-lived JWTs with strong signing keys
- Rotate API keys regularly
- Use MFA where possible

---

## API03:2023 - Broken Object Property Level Authorization

**Risk:** Medium — attackers read/write fields they shouldn't access.

### Testing Steps
- [ ] Identify sensitive fields in API responses:
  - [ ] `password`, `ssn`, `credit_card`, `email`, `role`
- [ ] Test for **mass assignment**:
  - [ ] Add `role: "admin"` to user update request
  - [ ] Add `is_verified: true` to account request
- [ ] Check if sensitive fields are returned in responses:
  - [ ] User profile returns password hash
  - [ ] Order details return other users' payment info
- [ ] Test PATCH/PUT requests with extra fields
- [ ] Verify that read-only fields can't be modified

### Tools
- Burp Suite Repeater
- Postman

### Remediation
- Whitelist allowed fields for each endpoint
- Strip sensitive fields from responses
- Reject unexpected fields in requests
- Use DTOs (Data Transfer Objects) to control exposure

---

## API04:2023 - Unrestricted Resource Consumption

**Risk:** High — attackers cause DoS or inflate costs.

### Testing Steps
- [ ] Test for **rate limiting**:
  - [ ] Send 1000+ requests in rapid succession
  - [ ] Check for `429 Too Many Requests` responses
- [ ] Test for **pagination limits**:
  - [ ] Request `?limit=999999` on list endpoints
  - [ ] Check for default page size (should be ≤ 100)
- [ ] Test for **file upload size limits**:
  - [ ] Upload 100MB+ files
  - [ ] Check for server-side size validation
- [ ] Test for **query complexity** (GraphQL):
  - [ ] Deeply nested queries
  - [ ] Queries with large result sets
- [ ] Check for **timeouts**:
  - [ ] Send long-running requests
  - [ ] Verify server enforces request timeouts

### Tools
- Burp Suite Intruder
- Apache Bench (`ab`)
- wrk
- Custom Python scripts

### Remediation
- Implement rate limiting per user/IP
- Enforce pagination limits (max 100 items per page)
- Set file upload size limits (e.g., 10MB)
- Add request timeouts (e.g., 30 seconds)
- Use query cost analysis for GraphQL

---

## API05:2023 - Broken Function Level Authorization

**Risk:** Critical — attackers access admin-only functions.

### Testing Steps
- [ ] Identify admin-only endpoints:
  - [ ] `POST /api/admin/users/delete`
  - [ ] `PUT /api/config/update`
- [ ] Test with low-privilege user tokens:
  - [ ] Can a regular user call admin endpoints?
- [ ] Check for **hidden endpoints**:
  - [ ] `/api/internal/*`
  - [ ] `/api/debug/*`
  - [ ] `/api/test/*`
- [ ] Test for **HTTP method bypass**:
  - [ ] Change `GET` to `POST` or `DELETE`
  - [ ] Use `X-HTTP-Method-Override` header
- [ ] Verify role-based access control (RBAC) on every endpoint

### Tools
- Burp Suite
- OWASP ZAP
- Custom scripts

### Remediation
- Enforce RBAC on every endpoint
- Deny by default (whitelist allowed methods)
- Remove or secure debug/test endpoints
- Log all admin actions for audit

---

## API06:2023 - Unrestricted Access to Sensitive Business Flows

**Risk:** Medium — attackers abuse business logic.

### Testing Steps
- [ ] Identify critical business flows:
  - [ ] Password reset
  - [ ] Account registration
  - [ ] Payment processing
  - [ ] Coupon/redemption codes
- [ ] Test for **automation abuse**:
  - [ ] Can password reset be automated?
  - [ ] Can accounts be created in bulk?
- [ ] Test for **logical flaws**:
  - [ ] Apply same coupon multiple times
  - [ ] Skip payment steps
  - [ ] Manipulate price/quantity in requests
- [ ] Check for **anti-automation controls**:
  - [ ] CAPTCHA on registration/login
  - [ ] Email/phone verification
  - [ ] Device fingerprinting

### Tools
- Burp Suite
- Selenium (for browser-based flows)
- Custom scripts

### Remediation
- Implement CAPTCHA on sensitive flows
- Add rate limiting per IP/user
- Use multi-step verification (email, SMS)
- Validate business logic server-side

---

## API07:2023 - Server Side Request Forgery (SSRF)

**Risk:** Critical — attackers access internal services.

### Testing Steps
- [ ] Identify parameters that accept URLs:
  - [ ] `?url=http://...`
  - [ ] `?redirect=http://...`
  - [ ] `?webhook=http://...`
- [ ] Test for **internal access**:
  - [ ] `http://127.0.0.1:8080`
  - [ ] `http://169.254.169.254/latest/meta-data/` (AWS metadata)
  - [ ] `http://localhost:6379` (Redis)
- [ ] Test for **DNS rebinding**:
  - [ ] Use a domain that resolves to internal IP
- [ ] Test for **protocol abuse**:
  - [ ] `file:///etc/passwd`
  - [ ] `gopher://`, `dict://`
- [ ] Check if server validates URL schemes and destinations

### Tools
- Burp Suite Collaborator
- interactsh
- Custom SSRF testing servers

### Remediation
- Whitelist allowed URL schemes (http, https only)
- Block internal IP ranges (10.x, 172.16-31.x, 192.168.x, 127.x)
- Use outbound firewalls
- Validate and sanitize all user-supplied URLs

---

## API08:2023 - Security Misconfiguration

**Risk:** High — default configs expose sensitive data.

### Testing Steps
- [ ] Check for **verbose error messages**:
  - [ ] Stack traces in responses
  - [ ] Internal IP addresses or paths
- [ ] Test for **missing security headers**:
  - [ ] `Content-Security-Policy`
  - [ ] `X-Content-Type-Options`
  - [ ] `Strict-Transport-Security`
- [ ] Check for **debug endpoints**:
  - [ ] `/debug/*`, `/trace/*`, `/actuator/*`
- [ ] Test for **CORS misconfiguration**:
  - [ ] `Access-Control-Allow-Origin: *` on sensitive endpoints
  - [ ] Reflective CORS (echoes `Origin` header)
- [ ] Verify **TLS configuration**:
  - [ ] No SSLv3/TLS 1.0
  - [ ] Strong cipher suites
- [ ] Check for **default credentials**:
  - [ ] Admin panels with `admin:admin`
  - [ ] API docs with default auth

### Tools
- Nmap SSL scripts
- testssl.sh
- Burp Suite
- SecurityHeaders.com

### Remediation
- Disable verbose errors in production
- Set security headers
- Remove debug endpoints
- Restrict CORS to trusted origins
- Enforce TLS 1.2+
- Change all default credentials

---

## API09:2023 - Improper Inventory Management

**Risk:** Medium — outdated or shadow APIs are exploited.

### Testing Steps
- [ ] Identify **API versions**:
  - [ ] `/api/v1/*`, `/api/v2/*`, `/api/v3/*`
  - [ ] Are old versions still active?
- [ ] Check for **shadow APIs**:
  - [ ] Undocumented endpoints
  - [ ] Developer/staging endpoints on production
- [ ] Test for **deprecated endpoints**:
  - [ ] `/api/legacy/*`
  - [ ] Old mobile app endpoints
- [ ] Verify **API documentation**:
  - [ ] Swagger/OpenAPI specs exposed
  - [ ] Are all documented endpoints intentional?

### Tools
- Burp Suite
- Dirb/Gobuster (for endpoint discovery)
- Swagger Inspector

### Remediation
- Decommission old API versions
- Document all endpoints
- Restrict access to staging/dev environments
- Regularly audit API inventory

---

## API10:2023 - Unsafe Consumption of APIs

**Risk:** High — trusting third-party APIs without validation.

### Testing Steps
- [ ] Identify **third-party API integrations**:
  - [ ] Payment gateways
  - [ ] OAuth providers
  - [ ] External data sources
- [ ] Test for **data validation**:
  - [ ] Does the app trust all data from third-party APIs?
  - [ ] Can an attacker inject data into the third-party response?
- [ ] Check for **TLS validation**:
  - [ ] Are external API calls using HTTPS?
  - [ ] Is certificate validation enforced?
- [ ] Test for **injection via third-party data**:
  - [ ] SQL injection in data from external APIs
  - [ ] XSS in rendered third-party content

### Tools
- Burp Suite
- MitM proxies for intercepting external calls
- Custom scripts

### Remediation
- Validate and sanitize all data from external APIs
- Enforce TLS for all outbound connections
- Implement input validation on third-party data
- Use allowlists for external API domains

---

## Quick Reference: Common API Vulnerabilities

| Vulnerability | Test Method | Impact |
|---------------|------------|--------|
| IDOR | Change object IDs | Data exposure |
| Broken Auth | Brute-force, JWT attacks | Account takeover |
| Mass Assignment | Add extra fields | Privilege escalation |
| Rate Limiting | Send 1000+ requests | DoS, cost inflation |
| SSRF | Internal URLs | Internal network access |
| CORS Misconfig | Check `Access-Control-Allow-Origin` | Data theft |
| Verbose Errors | Trigger errors | Info leakage |

---

## Tools Summary

- **Burp Suite** — Primary testing platform
- **Postman** — API exploration and testing
- **OWASP ZAP** — Open-source alternative to Burp
- **jwt.io** — JWT decoding and analysis
- **Hydra** — Brute-force testing
- **Nmap** — Service discovery and SSL checks
- **testssl.sh** — TLS/SSL configuration audit

---

*Last updated: 2026-04-06*
