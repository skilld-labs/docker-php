#!/usr/bin/env php
<?php

// Update files in drush.phar archive for PHP 8.1.
// https://www.php.net/manual/ru/phar.using.object.php

#if (!\Phar::canWrite()) my_fail("Can't write phar archives, use to run as 'php -dphar.readonly=0 patch.php'");

$drush = 'drush.phar';
$backup = "$drush.bak";
$src = 'https://github.com/drush-ops/drush/releases/download/8.4.8/drush.phar';
$patched_files = "files";
$hash = 'sha512';

if (!file_exists($drush)) {
  echo "File $drush is not found downloading...";
  $src = file_get_contents($src);
  if (!$src) my_fail("failed to get $src");
  $src = file_put_contents($drush, $src);
  if (!$src) my_fail("failed to save $drush");
  my_msg("ok");
}

if (!file_exists($backup)) {
  if (!copy($drush, $backup)) {
    my_fail("Failed to create backup $backup");
  }
  else {
    my_msg("Backup saved as $backup");
  }
}

\PharData::loadPhar($drush, $drush);

$directory = new \RecursiveDirectoryIterator($patched_files);
$iterator = new \RecursiveIteratorIterator($directory);

$replace = [];

/** @var \SplFileInfo $info */
foreach ($iterator as $info) {
  if ($info->isFile()) {
    $file = substr($info->getPathname(), strlen($patched_files) + 1);
    $replace[] = $file;
  }
}

foreach ($replace as $file) {
  my_replace($file);
}

my_msg("Patched $drush is ready for use");

$cleanup = [
  'docs',
  'examples',
  'misc/windrush_build',
  'vendor/doctrine',
  'vendor/phpdocumentor',
  'vendor/phpspec',
  'vendor/phpunit',
  'vendor/sebastian',
];

$delete = [];

$offset = strlen($drush) + 1;
$handle = new \Phar($drush);
/** @var \SplFileInfo $item */
foreach (new \RecursiveIteratorIterator($handle) as $item) {
  if ($item->isFile()) {
    $file = $item->getPathname();
    $file = substr($file, strpos($file, "$drush/") + $offset);
    foreach ($cleanup as $dir) {
      if (str_starts_with($file, $dir)) {
        $delete[] = $file;
      }
    }
  }
}

if (!$delete) {
  my_msg("Nothing to clean-up");
  exit(0);
}

foreach ($delete as $file) {
  my_delete($file);
}


function my_msg($msg) {
  echo $msg . PHP_EOL;
}

function my_fail($msg) {
  my_msg($msg);
  die(1);
}

function my_replace($file) {
  global $drush, $patched_files, $hash;
  $phar = "phar://$drush/$file";
  $old = file_get_contents($phar);
  $old_hash = hash($hash, $old);
  $new = file_get_contents("$patched_files/$file");
  $new_hash = hash($hash, $new);
  if ($old_hash !== $new_hash) {
    my_msg("Patching $file - $hash checksums old and new");
    my_msg($old_hash);
    my_msg($new_hash);
    $r = file_put_contents($phar, $new);
    if ($r) my_msg("Patched $file");
    else my_fail("Failed to patch $file");
  }
  else my_msg("File $file already patched");
}

function my_delete($file) {
  global $drush;
  $phar = "phar://$drush/$file";
  my_msg("Deleting file $file");
  if (file_exists($phar)) {
    unlink($phar);
  }
}
