<?php
require "db.php";

$name = trim($_POST['name']);
$email = trim($_POST['email']);
$password = password_hash($_POST['password'], PASSWORD_BCRYPT);

// Check if email already exists
$check = $pdo->prepare("SELECT id FROM users WHERE email = ?");
$check->execute([$email]);

if ($check->rowCount() > 0) {
    echo json_encode([
        "status" => "error",
        "msg" => "Email already registered"
    ]);
    exit;
}

// Insert user
$stmt = $pdo->prepare(
    "INSERT INTO users (name, email, password) VALUES (?, ?, ?)"
);
$stmt->execute([$name, $email, $password]);

echo json_encode([
    "status" => "success",
    "msg" => "Registration successful"
]);
