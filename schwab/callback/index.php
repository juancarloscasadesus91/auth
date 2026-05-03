<?php

$tunnelUrl = 'https://penguin-sending-homeland-linked.trycloudflare.com';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/callback' . ($query ? '?' . $query : ''));
exit;