<?php
// Vulnerable_Code/SQLi_Example.php
// WARNING: This is deliberately vulnerable to SQL Injection. Do not host in a production environment!

$servername = "localhost";
$username = "root";
$password = "password";
$dbname = "test_db";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Get user input directly from GET request
$user_id = $_GET['id'];

// THE VULNERABILITY: Directly concatenating user input into the SQL query without sanitization or prepared statements.
$sql = "SELECT username, email FROM users WHERE id = " . $user_id;

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        echo "User: " . $row["username"]. " - Email: " . $row["email"]. "<br>";
    }
} else {
    echo "0 results";
}

$conn->close();

/* 
### How to exploit this:
Normally, a call looks like: `?id=1`
An attacker can inject SQL logic: `?id=1 OR 1=1`
Resulting query: SELECT username, email FROM users WHERE id = 1 OR 1=1
This bypasses the ID check and returns ALL users in the database!

### How to fix this (Prepared Statements):
$stmt = $conn->prepare("SELECT username, email FROM users WHERE id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
*/
?>
