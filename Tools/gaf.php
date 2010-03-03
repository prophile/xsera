<?php

error_reporting(E_ALL | E_STRICT);

$filedata = '';
$files = array();

// step 1: find target files

function roundup($val, $to)
{
	$val = $val + ($to - 1);
	$val /= $to;
	$val *= $to;
	return $val;
}

$base = $argv[2];
function add_directory($base, $path = '/')
{
	global $files;
	global $filedata;
	$objects = scandir($base . $path);
	foreach ($objects as $obj)
	{
		if ($obj == '' || $obj[0] == '.')
			continue;
		if (is_dir("$base/$path$obj"))
			add_directory($base, "$path$obj/");
		else
		{
			$contents = file_get_contents("$base/$path$obj");
			$offset = roundup(strlen($filedata), 16);
			while (strlen($filedata) % 16 != 0)
				$filedata .= chr(0);
			$filedata .= $contents;
			$name = substr("$path$obj", 1);
			$files[$name] = array($offset, strlen($contents));
			unset($contents);
		}
	}
}

add_directory($base);

function pad($fp, $length, $multiple, $mod = 0)
{
	while ($length++ % $multiple != $mod)
		fwrite($fp, chr(0));
}

echo strlen($filedata) . "\n";

$out = fopen($argv[1], 'wb');
// write 8-byte magic number
fwrite($out, 'THEGAME!');
fwrite($out, pack('N', count($files)));
foreach ($files as $name => $file)
{
	fwrite($out, pack('n', strlen($name)));
	fwrite($out, $name);
	fwrite($out, chr(0));
	pad($out, strlen($name) + 1, 4, 2);
	fwrite($out, pack('N', $file[0]));
	fwrite($out, pack('N', $file[1]));
}
pad($out, ftell($out), 16);
fwrite($out, $filedata);
pad($out, strlen($filedata), 4);

?>
