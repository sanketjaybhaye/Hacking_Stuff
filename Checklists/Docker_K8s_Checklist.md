# Docker & Kubernetes Security Checklist

Security assessment checklist for containerized environments and orchestration platforms.

---

## Docker Security Checklist

### 1. Docker Daemon Security
- [ ] Verify daemon is not exposed over TCP without TLS:
  ```bash
  ss -tulpn | grep docker
  # Should NOT listen on 0.0.0.0:2375
  ```
- [ ] Check for rootless Docker mode:
  ```bash
  dockerd --rootless
  ```
- [ ] Verify user namespace remapping is enabled:
  ```bash
  cat /etc/docker/daemon.json | grep userns-remap
  ```

### 2. Container Configuration
- [ ] Check for privileged containers:
  ```bash
  docker ps --format "{{.Names}}: {{.Status}}" 
  docker inspect <container> | grep Privileged
  # Should be false
  ```
- [ ] Verify containers don't run as root:
  ```bash
  docker inspect <container> | grep -A5 User
  ```
- [ ] Check for dangerous capabilities:
  ```bash
  docker inspect <container> | grep -A10 CapAdd
  # Avoid: SYS_ADMIN, NET_ADMIN, SYS_PTRACE
  ```
- [ ] Verify read-only root filesystem:
  ```bash
  docker inspect <container> | grep ReadonlyRootfs
  ```

### 3. Image Security
- [ ] Scan images for vulnerabilities:
  ```bash
  trivy image <image_name>
  docker scout cves <image_name>
  ```
- [ ] Check for sensitive data in layers:
  ```bash
  dive <image_name>
  history --no-trunc <image_name>
  ```
- [ ] Verify images are from trusted registries
- [ ] Check for hardcoded secrets in Dockerfiles:
  ```bash
  grep -i "password\|secret\|key" Dockerfile
  ```

### 4. Network Security
- [ ] Verify containers are on isolated networks:
  ```bash
  docker network ls
  docker network inspect <network>
  ```
- [ ] Check for exposed ports bound to `0.0.0.0`:
  ```bash
  docker ps --format "table {{.Names}}\t{{.Ports}}"
  ```
- [ ] Verify no inter-container communication unless needed

### 5. Volume & Mount Security
- [ ] Check for sensitive host mounts:
  ```bash
  docker inspect <container> | grep -A5 Mounts
  # Avoid: /, /etc, /var/run/docker.sock
  ```
- [ ] Verify Docker socket is not mounted:
  ```bash
  # /var/run/docker.sock mounted = container escape risk
  ```

### 6. Resource Limits
- [ ] Verify CPU/memory limits are set:
  ```bash
  docker inspect <container> | grep -A5 Memory
  docker inspect <container> | grep -A5 CpuQuota
  ```
- [ ] Check for PID limits to prevent fork bombs

---

## Kubernetes Security Checklist

### 1. API Server Security
- [ ] Verify API server is not exposed publicly:
  ```bash
  kubectl cluster-info
  nmap -p 6443 <api_server_ip>
  ```
- [ ] Check for anonymous authentication:
  ```bash
  kubectl get nodes --insecure-skip-tls-verify
  # Should fail if auth is enforced
  ```
- [ ] Verify RBAC is enabled:
  ```bash
  kubectl auth can-i --list
  ```

### 2. Pod Security
- [ ] Check for privileged pods:
  ```bash
  kubectl get pods --all-namespaces -o json | jq '.items[] | select(.spec.containers[].securityContext.privileged == true)'
  ```
- [ ] Verify pods don't run as root:
  ```bash
  kubectl get pods --all-namespaces -o json | jq '.items[] | select(.spec.containers[].securityContext.runAsUser == 0)'
  ```
- [ ] Check for hostPath volumes:
  ```bash
  kubectl get pods --all-namespaces -o json | jq '.items[] | select(.spec.volumes[].hostPath != null)'
  ```
- [ ] Verify resource limits are set:
  ```bash
  kubectl describe pod <pod> | grep -A5 Limits
  ```

### 3. RBAC & Service Accounts
- [ ] Check for overly permissive roles:
  ```bash
  kubectl get clusterroles | grep -E "cluster-admin|edit|admin"
  kubectl get clusterrolebindings -o json | jq '.items[] | select(.roleRef.name == "cluster-admin")'
  ```
- [ ] Verify default service accounts are not used:
  ```bash
  kubectl get pods --all-namespaces -o json | jq '.items[] | select(.spec.serviceAccountName == "default")'
  ```
- [ ] Check for token automounting:
  ```bash
  kubectl get sa --all-namespaces -o json | jq '.items[] | select(.automountServiceAccountToken != false)'
  ```

### 4. Secrets Management
- [ ] Check for secrets in environment variables:
  ```bash
  kubectl get pods --all-namespaces -o json | jq '.items[].spec.containers[].env[] | select(.valueFrom == null)'
  ```
- [ ] Verify secrets are encrypted at rest:
  ```bash
  kubectl get secrets --all-namespaces -o json | jq '.items[].data'
  # Should be encrypted in etcd
  ```
- [ ] Check for secrets mounted as volumes (preferred over env vars)

### 5. Network Policies
- [ ] Verify network policies are enforced:
  ```bash
  kubectl get networkpolicies --all-namespaces
  ```
- [ ] Check for default-deny policies:
  ```bash
  kubectl get networkpolicies --all-namespaces -o json | jq '.items[] | select(.spec.podSelector == {})'
  ```
- [ ] Verify inter-namespace communication is restricted

### 6. Admission Controllers
- [ ] Check for PodSecurity admission:
  ```bash
  kubectl get namespaces --show-labels | grep pod-security
  ```
- [ ] Verify OPA/Gatekeeper policies are enforced
- [ ] Check for image signature verification

### 7. Logging & Monitoring
- [ ] Verify audit logging is enabled:
  ```bash
  cat /etc/kubernetes/audit-policy.yaml
  ```
- [ ] Check for Falco or similar runtime security
- [ ] Verify log aggregation is configured

---

## Container Escape Techniques

### Docker Escapes
- [ ] **Privileged container**:
  ```bash
  # Mount host filesystem
  docker run -it --privileged -v /:/host alpine chroot /host /bin/sh
  ```
- [ ] **Docker socket mounted**:
  ```bash
  # Create new container with host access
  docker -H unix:///var/run/docker.sock run -it -v /:/host alpine chroot /host /bin/sh
  ```
- [ ] **Writable procfs**:
  ```bash
  # Modify kernel parameters
  echo 1 > /proc/sys/kernel/core_pattern
  ```

### Kubernetes Escapes
- [ ] **Privileged pod**:
  ```bash
  # Same as Docker privileged escape
  ```
- [ ] **HostPath mount**:
  ```bash
  # Access host filesystem via mounted path
  cat /host/etc/shadow
  ```
- [ ] **Service account token abuse**:
  ```bash
  # Use pod's SA token to query API server
  curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://<api-server>/api/v1/namespaces
  ```

---

## Tools Summary

| Tool | Purpose | URL |
|------|---------|-----|
| Trivy | Image vulnerability scanner | github.com/aquasecurity/trivy |
| Dive | Docker image layer explorer | github.com/wagoodman/dive |
| Kube-bench | CIS benchmark checker | github.com/aquasecurity/kube-bench |
| Kube-hunter | Kubernetes penetration tool | github.com/aquasecurity/kube-hunter |
| Falco | Runtime security monitoring | falco.org |
| Clair | Container image scanning | github.com/quay/clair |
| CDK | Container escape toolkit | github.com/cdk-team/CDK |

---

## Quick Reference: Critical Misconfigurations

| Misconfiguration | Risk | Detection |
|------------------|------|-----------|
| Privileged container | Full host access | `docker inspect` |
| Docker socket mounted | Container escape | Check mounts |
| Host PID namespace | Process visibility | `kubectl get pod -o yaml` |
| Cluster-admin binding | Full cluster control | `kubectl get clusterrolebindings` |
| Anonymous API access | Unauthenticated access | Test with curl |
| No network policies | Lateral movement | `kubectl get networkpolicies` |

---

*Last updated: 2026-04-06*
