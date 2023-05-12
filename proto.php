<?php

//phpinfo();

$dsn = "sqlite:db/dat.db";

$options = [
	PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
	PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
	PDO::ATTR_EMULATE_PREPARES => false,
];

try {
	$pdo = new PDO($dsn, null, null, $options);
} catch (\PDOException $e) {
	throw new \PDOException($e->getMessage(), (int)$e->getCode());
}
/*
$stmt = $pdo->query('select * from users');

while ($row = $stmt->fetch())
{
	echo $row['name'] . "<br>" . PHP_EOL;
}
*/
$sql = 'select * from users';

foreach ($pdo->query($sql) as $row)
{
	print $row['name'] . "\t";
	print $row['pass'] . "\t";
	print $row['rand'] . "\n";
}
