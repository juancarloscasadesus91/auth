<?php

$tunnelUrl = 'https://volvo-renewable-survive-ash.trycloudflare.com';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/trader/callback' . ($query ? '?' . $query : ''));
exit;