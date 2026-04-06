<?php
/**
 * Vulnerable Code Example: OS Command Injection
 * Description: User input is passed directly to shell command execution without validation.
 * Vulnerability: CWE-78 - Improper Neutralization of Special Elements used in an OS Command
 * Impact: Attackers can execute arbitrary system commands, leading to full server compromise.
 *
 * Disclaimer: For educational purposes only. Do not deploy this code in production.
 */

// Vulnerable Code
if (isset($_GET['ip'])) {
    $ip = $_GET['ip'];
    // Dangerous: User input directly concatenated into shell command
    $output = shell_exec("ping -c 4 " . $ip);
    echo "<pre>{$output}</pre>";
}

/*
 * Exploit Example:
 * GET /vuln.php?ip=127.0.0.1; cat /etc/passwd
 * GET /vuln.php?ip=127.0.0.1|whoami
 *
 * Remediation:
 * 1. Use escapeshellarg() to sanitize input:
 *    $output = shell_exec("ping -c 4 " . escapeshellarg($ip));
 *
 * 2. Better: Use native PHP functions instead of shell commands:
 *    Use fsockopen() or built-in network libraries.
 *
 * 3. Validate input against a whitelist (e.g., IP regex):
 *    if (preg_match('/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/', $ip)) { ... }
 */
?>
