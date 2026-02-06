<?php
// Test script to verify MongoDB and PDO extensions
echo "<h1>PHP Extension Status</h1>";

echo "<h2>Loaded Extensions:</h2>";
$extensions = get_loaded_extensions();

$required = ['mongodb', 'pdo', 'pdo_mysql'];
foreach ($required as $ext) {
    if (in_array($ext, $extensions)) {
        echo "✓ $ext: <strong style='color: green;'>LOADED</strong><br>";
    } else {
        echo "✗ $ext: <strong style='color: red;'>MISSING</strong><br>";
    }
}

echo "<h2>MongoDB Driver Info:</h2>";
try {
    if (extension_loaded('mongodb')) {
        $version = phpversion('mongodb');
        echo "MongoDB Extension Version: <strong>$version</strong><br>";
        echo "MongoDB Driver is ready for Composer package use.<br>";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}

echo "<h2>PDO MySQL Info:</h2>";
try {
    if (extension_loaded('pdo_mysql')) {
        echo "PDO MySQL Driver: <strong style='color: green;'>AVAILABLE</strong><br>";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}

echo "<h2>System Info:</h2>";
echo "PHP Version: " . phpversion() . "<br>";
echo "Server: " . $_SERVER['SERVER_SOFTWARE'] . "<br>";
echo "Hostname: " . gethostname() . "<br>";
?>
