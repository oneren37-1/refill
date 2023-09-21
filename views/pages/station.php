<?php

global $conn;
require(dirname(__DIR__).'/utils/db_connection.php');
session_start();

if (!isset($_GET["id"])) {
    header("Location: /refill");
    exit();
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if(isset($_POST['comment'])) {
        $message = $_POST['comment'];
        $station = $_GET["id"];
        $user = $_SESSION['user_uid'];

        $stmt = $conn->prepare("insert into comment (station, user, message) values (:s, :u, :m)");
        $stmt->bindParam(':m', $message);
        $stmt->bindParam(':s', $station);
        $stmt->bindParam(':u', $user);

        if ($stmt->execute()) {
            echo "<meta http-equiv='refresh' content='0'>";
        } else {
            echo "Произошла ошибка при выполнении запроса!";
        }
    }

    if(isset($_POST['delete_comment'])) {
        $stmt = $conn->prepare("delete from comment where sid = :id");
        $stmt->bindParam(':id', $_POST['delete_comment']);
        if ($stmt->execute()) {
            echo "<meta http-equiv='refresh' content='0'>";
        } else {
            echo "Произошла ошибка при выполнении запроса!";
        }
    }
}

$stmt = $conn->prepare("SELECT * FROM station WHERE sid = :id");
$stmt->bindParam(':id', $_GET["id"]);
$stmt->execute();
$data = $stmt->fetch(PDO::FETCH_ASSOC);

$stmt = $conn->prepare("SELECT * FROM comments WHERE station=:id");
$stmt->bindParam(':id', $_GET["id"]);
$stmt->execute();

$comments = [];
while ($row = $stmt->fetch()) {
    array_push($comments, $row);
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
    <style><?php include(dirname(__DIR__).'/css/common.css');?></style>
    <title>Refill</title>
</head>
<body>
<?php include(dirname(__DIR__).'/components/header.php');?>
<div class="page-wrapper">
    <div class="container">
        <div class="row">
            <div class="col-md-6">
                <img src="<?php echo($data["img"]) ?>" alt="Изображение заправки" class="img-fluid">
            </div>
            <div class="col-md-6">
                <h1><?php echo($data["location"]) ?></h1>
                <p>Описание заправки:</p>
                <p><?php echo($data["description"]) ?></p>
            </div>
        </div>
        <div class="row mt-5">
            <div class="col-md-12">
                <h2>Комментарии</h2>
                <?php foreach ($comments as $comment): ?>
                    <div class="card mt-2">
                        <div class="card-body">
                            <h5 class="card-title"><?php echo($comment["login"]) ?></h5>
                            <p class="card-text"><?php echo($comment["message"]) ?></p>
                            <p class="card-text"><?php echo($comment["date"]) ?></p>

                            <?php if (isset($_SESSION["user_login"]) && $_SESSION["user_role"] == 2): ?>
                                <form method="post" enctype="multipart/form-data" class="mb-2">
                                    <input type="text" hidden name="delete_comment" value="<?php echo($comment["sid"])?>">
                                    <button type="submit" class="btn btn-danger">Удалить</button>
                                </form>
                            <?php endif; ?>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
            <?php if (isset($_SESSION["user_login"])):?>
                <div class="mt-4 mb-5">
                    <h2>Оставить комментарий</h2>
                    <form method="post" enctype="multipart/form-data">
                        <div class="form-group">
                            <label for="comment">Комментарий:</label>
                            <textarea class="form-control" id="comment" name="comment" rows="4" required></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary">Отправить</button>
                    </form>
                </div>
            <?php endif;?>
        </div>
    </div>
</div>
</body>
</html>
