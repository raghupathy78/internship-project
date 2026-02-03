<?php
require "redis.php";
require "mongo.php";

$token = $_POST['token'];
$userId = $redis->get("session_$token");

if (!$userId) {
    echo json_encode(["status" => "unauthorized"]);
    exit;
}

// Save / update profile
$collection->updateOne(
    ["user_id" => (int)$userId],
    [
        '$set' => [
            "age" => $_POST['age'],
            "dob" => $_POST['dob'],
            "contact" => $_POST['contact']
        ]
    ],
    ["upsert" => true]
);

echo json_encode(["status" => "success"]);
