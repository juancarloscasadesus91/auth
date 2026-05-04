<?php

$tunnelUrl = 'https://los-shortcuts-cal-metres.trycloudflare.com';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/callback' . ($query ? '?' . $query : ''));
exit;