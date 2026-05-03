<?php

$tunnelUrl = 'https://geological-reload-shelter-variables.trycloudflare.com';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/callback' . ($query ? '?' . $query : ''));
exit;