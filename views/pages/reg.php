<?php

global $conn;
require(dirname(__DIR__).'/utils/db_connection.php');

if($_SERVER["REQUEST_METHOD"] == "POST") {
    $stmt = $conn->prepare("call create_user(:login, :password, :email)");
    $stmt->bindParam(':login', $_POST["login"]);
    $stmt->bindParam(':password', $_POST["password"]);
    $stmt->bindParam(':email', $_POST["email"]);

    if ($stmt->execute()) {
        header("Location: /refill/auth");
        exit();
    } else {
        echo "Произошла ошибка при выполнении запроса!";
    }
}

?>



<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
    <title>Регистрация</title>

    <style>
        .form-container {
            width: 200px;
            padding-top: 100px;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="form-container">
        <form method="post">
            <div class="mb-3">
                <label class="form-label">Логин</label>
                <input type="text" required class="form-control" name="login">
            </div>
            <div class="mb-3">
                <label class="form-label">Email</label>
                <input type="email" required class="form-control" name="email">
            </div>
            <div class="mb-3">
                <label class="form-label">Пароль</label>
                <input type="password" required class="form-control" name="password">
            </div>
            <button type="submit" class="btn btn-primary">Зарегистрироваться</button>
            <a href="/refill/auth">Войти</a>
        </form>
    </div>
    
</body>
</html>