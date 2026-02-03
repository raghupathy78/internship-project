<?php
require "db.php";
require "redis.php";

$email = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

$stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
$stmt->execute([$email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user && password_verify($password, $user['password'])) {

    $token = bin2hex(random_bytes(16));
    $redis->setex("session_$token", 3600, $user['id']);

    echo json_encode([
        "status" => "success",
        "token" => $token
    ]);
} else {
    echo json_encode(["status" => "fail"]);
}
