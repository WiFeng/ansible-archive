<?php
error_reporting(0);
if (php_sapi_name() == 'cli') {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1/opcache.php');
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Host: opcache.io'));
    curl_exec($ch);
    curl_close($ch);
} else {
    opcache_reset();
}

?>
