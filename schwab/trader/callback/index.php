<?php

$tunnelUrl = 'https://outsourcing-bumper-psychological-muscles.trycloudflare.com';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/trader/callback' . ($query ? '?' . $query : ''));
exit;