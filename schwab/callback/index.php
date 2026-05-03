<?php

$tunnelUrl = 'https://treatment-scotia-corporation-cursor.trycloudflare.com';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/callback' . ($query ? '?' . $query : ''));
exit;