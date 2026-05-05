<?php

$tunnelUrl = 'https://market.synergyplatform.net';

$query = $_SERVER['QUERY_STRING'] ?? '';

header('Location: ' . $tunnelUrl . '/auth/schwab/callback' . ($query ? '?' . $query : ''));
exit;