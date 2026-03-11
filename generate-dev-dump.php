<?php

/**
 * PHP-based Database Dump and Scramble Tool
 *
 * This script connects to the database, fetches data, applies custom
 * scrambling logic to sensitive fields, and outputs a SQL dump.
 */

// Configuration
$host = getenv('DB_HOST') ?: 'database';
$user = 'root'; // Use root to ensure we can read all tables
$pass = getenv('MYSQL_ROOT_PASSWORD') ?: 'tiger';
$dbname = 'hospital'; // The database we created in hospital.sql
$outputFile = '/var/www/html/dev-initdb-scrambled-php.sql';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    echo "### Connected to database: $dbname\n";

    $handle = fopen($outputFile, 'w');
    if (!$handle) {
        throw new Exception("Cannot open file for writing: $outputFile");
    }

    // Write database creation and usage
    fwrite($handle, "CREATE DATABASE IF NOT EXISTS `$dbname`;\n");
    fwrite($handle, "USE `$dbname`;\n\n");

    // Get all tables
    $tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);

    foreach ($tables as $table) {
        echo "### Processing table: $table\n";

        // Get Table Structure
        $createTable = $pdo->query("SHOW CREATE TABLE `$table`")->fetch();
        fwrite($handle, $createTable['Create Table'] . ";\n\n");

        // Get Data
        $stmt = $pdo->query("SELECT * FROM `$table`");
        while ($row = $stmt->fetch()) {
            // Apply Scrambling Logic
            if ($table === 'patients') {
                $row['name'] = scrambleName($row['name']);
                $row['email'] = scrambleEmail($row['email'], $row['id']);
            }

            // Generate INSERT statement
            $columns = array_keys($row);
            $values = array_values($row);
            $escapedValues = array_map(function($val) use ($pdo) {
                if ($val === null) return 'NULL';
                return $pdo->quote($val);
            }, $values);

            $sql = sprintf(
                "INSERT INTO `%s` (`%s`) VALUES (%s);\n",
                $table,
                implode("`, `", $columns),
                implode(", ", $escapedValues)
            );
            fwrite($handle, $sql);
        }
        fwrite($handle, "\n");
    }

    fclose($handle);
    echo "### Scrambled dump created: $outputFile\n";

} catch (PDOException $e) {
    echo "### Database Error: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "### Error: " . $e->getMessage() . "\n";
    exit(1);
}

/**
 * Custom Scrambling Logics
 */

function scrambleName($name) {
    $firstNames = ['John', 'Jane', 'Alex', 'Sam', 'Taylor', 'Jordan', 'Casey'];
    $lastNames = ['Smith', 'Doe', 'Brown', 'Wilson', 'Taylor', 'Clark', 'Lewis'];

    return $firstNames[array_rand($firstNames)] . ' ' . $lastNames[array_rand($lastNames)];
}

function scrambleEmail($email, $id) {
    // Generate a consistent but scrambled email
    return "user" . $id . "@dev.example.com";
}
