<?php
/**
 * Vulnerable Code Example: Insecure Direct Object Reference (IDOR)
 * Description: User-controlled ID is used to fetch data without proper authorization checks.
 * Vulnerability: CWE-639 - Authorization Bypass Through User-Controlled Key
 * Impact: Attackers can access other users' private data by changing the ID parameter.
 *
 * Disclaimer: For educational purposes only. Do not deploy this code in production.
 */

// Simulated database
$users = [
    1 => ['name' => 'Alice', 'email' => 'alice@example.com', 'ssn' => '123-45-6789'],
    2 => ['name' => 'Bob', 'email' => 'bob@example.com', 'ssn' => '987-65-4321'],
];

// Vulnerable Code
if (isset($_GET['user_id'])) {
    $user_id = (int)$_GET['user_id'];
    
    // No authorization check - any user can view any other user's data
    if (isset($users[$user_id])) {
        $user = $users[$user_id];
        echo "Name: " . htmlspecialchars($user['name']) . "<br>";
        echo "Email: " . htmlspecialchars($user['email']) . "<br>";
        echo "SSN: " . htmlspecialchars($user['ssn']) . "<br>"; // Sensitive data exposed!
    } else {
        echo "User not found.";
    }
}

/*
 * Exploit Example:
 * GET /vuln.php?user_id=1  → Alice's data
 * GET /vuln.php?user_id=2  → Bob's data (unauthorized access!)
 *
 * Remediation:
 * 1. Implement proper authorization checks:
 *    if ($user_id !== $_SESSION['user_id']) { die("Unauthorized"); }
 *
 * 2. Use indirect references (UUIDs instead of sequential IDs):
 *    $uuid_map = ['abc-123' => 1, 'def-456' => 2];
 *    $user_id = $uuid_map[$_GET['uuid']];
 *
 * 3. Never expose sensitive fields (SSN, password hashes) in API responses.
 */
?>
