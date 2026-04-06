# Cloud Security Penetration Testing Checklist

Based on **CSA Cloud Controls Matrix** and **OWASP Cloud Security**. Use this checklist during authorized cloud infrastructure assessments (AWS, Azure, GCP).

---

## Phase 1: Reconnaissance & Discovery

### Asset Discovery
- [ ] Identify cloud provider (AWS, Azure, GCP, Oracle, IBM)
- [ ] Map all public-facing assets:
  - [ ] IP ranges (`whois`, `bgp lookups`)
  - [ ] Subdomains (`subfinder`, `amass`, `crt.sh`)
  - [ ] S3 buckets/Azure blobs/GCS buckets (`bucket_finder`, `cloud_enum`)
  - [ ] API endpoints (`/api/`, `/graphql`, Swagger docs)
- [ ] Check for exposed dashboards:
  - [ ] Kibana, Grafana, Jenkins, GitLab
  - [ ] Cloud provider consoles ( accidentally public)

### DNS & Domain Analysis
- [ ] Enumerate subdomains:
  ```bash
  subfinder -d example.com -o subs.txt
  amass enum -d example.com -o amass_subs.txt
  ```
- [ ] Check for takeovers (use `sub_takeover.sh` script)
- [ ] Analyze DNS records for misconfigurations:
  - [ ] CNAME pointing to unclaimed services
  - [ ] SPF/DKIM/DMARC records

---

## Phase 2: AWS Security Checklist

### S3 Buckets
- [ ] Enumerate buckets:
  ```bash
  aws s3 ls --no-sign-request
  bucket_finder.rb wordlist.txt
  ```
- [ ] Check for public read/write:
  ```bash
  aws s3 ls s3://bucket-name --no-sign-request
  aws s3 cp test.txt s3://bucket-name/ --no-sign-request
  ```
- [ ] Look for sensitive data:
  - [ ] `id_rsa`, `.env`, `config.php`, `credentials`
  - [ ] Database dumps, backups

### IAM & Permissions
- [ ] Check for overly permissive policies:
  - [ ] `*:*` (full admin)
  - [ ] `s3:*`, `ec2:*`, `lambda:InvokeFunction`
- [ ] Look for hardcoded credentials:
  - [ ] GitHub repos, public code snippets
  - [ ] `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- [ ] Test for privilege escalation paths:
  - [ ] `iam:PutUserPolicy`
  - [ ] `iam:AttachUserPolicy`
  - [ ] `sts:AssumeRole`

### EC2 & Compute
- [ ] Check for exposed management interfaces:
  - [ ] SSH (22), RDP (3389) open to `0.0.0.0/0`
  - [ ] Database ports (3306, 5432, 27017) public
- [ ] Check for instance metadata service (IMDS) exposure:
  ```bash
  curl http://169.254.169.254/latest/meta-data/
  curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
  ```
- [ ] Verify IMDSv2 is enforced (SSRF protection)

### Lambda & Serverless
- [ ] Check for exposed Lambda functions:
  ```bash
  aws lambda list-functions --region us-east-1
  ```
- [ ] Test for injection in function code
- [ ] Check environment variables for secrets

### API Gateway
- [ ] Enumerate API endpoints
- [ ] Check for missing authentication
- [ ] Test for rate limiting bypass
- [ ] Check for excessive data exposure

---

## Phase 3: Azure Security Checklist

### Storage Accounts
- [ ] Enumerate storage accounts:
  ```bash
  az storage account list --output table
  ```
- [ ] Check for public blob access:
  ```bash
  curl https://<account>.blob.core.windows.net/<container>/file.txt
  ```
- [ ] Look for sensitive data in blobs

### Azure AD (Entra ID)
- [ ] Check for guest user privileges
- [ ] Enumerate users and groups:
  ```bash
  az ad user list --output table
  az ad group list --output table
  ```
- [ ] Check for overprivileged service principals
- [ ] Test for password spray attacks

### Virtual Machines
- [ ] Check for exposed RDP/SSH
- [ ] Verify NSG (Network Security Group) rules
- [ ] Check for managed identity abuse

### Key Vault
- [ ] Check for misconfigured access policies
- [ ] Test for unauthorized secret access:
  ```bash
  az keyvault secret list --vault-name <vault>
  ```

---

## Phase 4: GCP Security Checklist

### Cloud Storage (GCS)
- [ ] Enumerate buckets:
  ```bash
  gsutil ls gs://
  ```
- [ ] Check for public read/write:
  ```bash
  curl https://storage.googleapis.com/<bucket>/file.txt
  ```
- [ ] Look for sensitive data

### IAM & Service Accounts
- [ ] Check for overly permissive roles:
  - [ ] `roles/owner`
  - [ ] `roles/editor`
  - [ ] `roles/iam.serviceAccountTokenCreator`
- [ ] Enumerate service accounts:
  ```bash
  gcloud iam service-accounts list
  ```
- [ ] Check for metadata server access:
  ```bash
  curl "http://metadata.google.internal/computeMetadata/v1/" -H "Metadata-Flavor: Google"
  ```

### Kubernetes (GKE)
- [ ] Check for exposed Kubernetes API
- [ ] Test for anonymous access
- [ ] Check for privileged containers
- [ ] Look for secrets in environment variables

### Cloud Functions
- [ ] Enumerate functions:
  ```bash
  gcloud functions list
  ```
- [ ] Check for unauthenticated triggers
- [ ] Test for injection vulnerabilities

---

## Phase 5: Common Cloud Misconfigurations

### Storage
- [ ] Public S3 buckets / Azure blobs / GCS buckets
- [ ] Unencrypted data at rest
- [ ] Missing versioning/logging

### Compute
- [ ] Security groups allowing `0.0.0.0/0`
- [ ] Missing WAF / Shield / DDoS protection
- [ ] Unpatched instances

### Identity
- [ ] MFA not enforced
- [ ] Root account used for daily tasks
- [ ] Long-lived access keys
- [ ] Overprivileged roles

### Networking
- [ ] VPC peering misconfigurations
- [ ] Exposed databases
- [ ] Missing network segmentation

### Monitoring
- [ ] CloudTrail/Azure Monitor/Stackdriver disabled
- [ ] No alerting on suspicious activity
- [ ] Logs not retained

---

## Phase 6: Exploitation Techniques

### SSRF to Cloud Metadata
```bash
# AWS IMDSv1
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Azure IMDS
curl -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/"

# GCP IMDS
curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"
```

### Cloud-Specific Tools
- [ ] **Pacu** — AWS exploitation framework
- [ ] **ScoutSuite** — Multi-cloud security auditor
- [ ] **CloudSploit** — Cloud configuration scanner
- [ ] **Steampipe** — Cloud inventory queries

### Privilege Escalation Paths
- [ ] AWS: `iam:PutUserPolicy` → attach admin policy
- [ ] Azure: `Microsoft.Authorization/roleAssignments/write` → grant Owner
- [ ] GCP: `iam.serviceAccounts.getAccessToken` → impersonate SA

---

## Quick Reference: Cloud-Specific Commands

| Provider | Command | Purpose |
|----------|---------|---------|
| AWS | `aws sts get-caller-identity` | Check current identity |
| AWS | `aws s3 ls` | List S3 buckets |
| Azure | `az ad signed-in-user show` | Check current user |
| Azure | `az storage account list` | List storage accounts |
| GCP | `gcloud auth list` | List authenticated accounts |
| GCP | `gsutil ls` | List GCS buckets |

---

## Tools Summary

| Tool | Provider | Purpose |
|------|----------|---------|
| Pacu | AWS | Exploitation framework |
| ScoutSuite | Multi-cloud | Security auditing |
| CloudSploit | Multi-cloud | Configuration scanning |
| bucket_finder | AWS | S3 bucket enumeration |
| cloud_enum | Multi-cloud | Resource discovery |
| az cli | Azure | Azure management |
| gcloud | GCP | GCP management |
| aws cli | AWS | AWS management |

---

*Last updated: 2026-04-06*
