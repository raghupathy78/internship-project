<?php
$redisClass = 'Redis';

if (!class_exists($redisClass)) {
	throw new RuntimeException('The PHP Redis extension is not installed or enabled.');
}

$redis = new $redisClass();
$redis->connect('127.0.0.1', 6379);
