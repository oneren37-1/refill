<?php

require_once realpath(__DIR__ . '/vendor/autoload.php');

// Looing for .env at the root directory
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ );
$dotenv->load();


if(isset($_GET['url'])) {
    $url = $_GET['url'];
} else {
    $url = 'home';
}

switch ($url) {
    case 'home':
        include './views/pages/home.php';
        break;
    case 'station':
        include './views/pages/station.php';
        break;
    case 'auth':
        include './views/pages/auth.php';
        break;
    case 'reg':
        include './views/pages/reg.php';
        break;
    case 'logout':
        include './views/pages/logout.php';
        break;
    case 'profile':
        include './views/pages/profile.php';
        break;
    case 'mail':
        include './views/pages/sender.php';
        break;
    default:
        include './views/pages/404.php';
        break;
}