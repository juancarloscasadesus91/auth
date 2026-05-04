<?php

$tunnelUrl = 'https://veterans-landscapes-crossing-covering.trycloudflare.com';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/trader/callback' . ($query ? '?' . $query : ''));
exit;