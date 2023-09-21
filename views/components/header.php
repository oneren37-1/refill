<?php

global $conn;
require(dirname(__DIR__).'/utils/db_connection.php');
session_start();

?>
<nav class="container navbar navbar-expand-lg navbar-light bg-light">
    <div class="container-fluid">
        <a class="navbar-brand" href="/refill">Роснефть</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
        </button>
        <div class="user-nav">
            <?php if (isset($_SESSION['user_login'])):?>
                <a href="./profile" class="nav-link"><?php echo($_SESSION["user_login"])?></a>
                <a href="./logout" class="nav-link">Выйти</a>
            <?php else:?>
                <a href="./auth" class="nav-link">Войти</a>
            <?php endif?>
        </div>
    </div>
</nav>