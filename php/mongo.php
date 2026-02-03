<?php
require_once __DIR__ . '/../vendor/autoload.php';

use MongoDB\Client;

$mongo = new Client("mongodb://localhost:27017");
$collection = $mongo->internship->profiles;
