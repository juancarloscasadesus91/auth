<?php

$tunnelUrl = 'https://racing-mixing-kelkoo-posting.trycloudflare.com';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/trader/callback' . ($query ? '?' . $query : ''));
exit;