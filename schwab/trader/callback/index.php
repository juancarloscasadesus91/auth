<?php

$tunnelUrl = 'https://established-dosage-celebs-climb.trycloudflare.com';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/trader/callback' . ($query ? '?' . $query : ''));
exit;