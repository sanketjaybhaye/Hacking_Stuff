<?php
/**
 * Vulnerable Code Example: Reflected Cross-Site Scripting (XSS)
 * Description: User input from GET parameter is reflected directly into HTML without sanitization.
 * Vulnerability: CWE-79 - Improper Neutralization of Input During Web Page Generation
 * Impact: Attackers can inject malicious JavaScript to steal cookies, session tokens, or perform actions on behalf of the user.
 *
 * Disclaimer: For educational purposes only. Do not deploy this code in production.
 */

// Vulnerable Code
if (isset($_GET['name'])) {
    $name = $_GET['name'];
    echo "<h1>Welcome, " . $name . "!</h1>";
}

/*
 * Exploit Example:
 * GET /vuln.php?name=<script>alert('XSS')</script>
 *
 * Remediation:
 * Use htmlspecialchars() to escape output:
 * echo "<h1>Welcome, " . htmlspecialchars($name, ENT_QUOTES, 'UTF-8') . "!</h1>";
 */
?>
