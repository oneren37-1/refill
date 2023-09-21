<?php

session_start();
if(isset($_SESSION['user_login'])){
    session_destroy();
}
header("Location: home");
exit();