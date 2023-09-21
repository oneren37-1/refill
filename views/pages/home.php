<?php

global $conn;
require(dirname(__DIR__).'/utils/db_connection.php');
session_start();

$stmt = $conn->prepare("SELECT * FROM station");
$stmt->execute();

$stations = [];
while ($row = $stmt->fetch()) {
    array_push($stations, $row);
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
        <?php include(dirname(__DIR__).'/components/fuelPrice.php');?>

        <div class="container mt-3 mb-5">
            <h1>Заправки</h1>

            <?php if (isset($_SESSION['user_login']) && $_SESSION['user_role'] == "2"): ?>
                <!-- Button trigger modal -->
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addStationModal">
                    Добавить заправку
                </button>
                <?php include(dirname(__DIR__).'/components/addStation.php');?>
            <?php endif; ?>
            <?php
            $cardCount = count($stations);
            $cardsPerRow = 3;

            for ($i = 0; $i < $cardCount; $i++) {
                $station = $stations[$i];
                if ($i % $cardsPerRow == 0) {
                    echo '<div class="row mt-5">';
                }
                ?>
                <div class="col-md-4">
                    <div class="card">
                        <img src="<?php echo($station["img"])?>" alt="Товар 1" class="card-img-top">
                        <div class="card-body">
                            <h5 class="card-title"><?php echo($station["location"])?></h5>
                            <a href="/refill/station?id=<?php echo($station["sid"])?>" class="btn btn-primary">Подробнее</a>
                        </div>
                    </div>
                </div>
            <?php
                if (($i + 1) % $cardsPerRow == 0 || $i == ($cardCount - 1)) {
                    echo '</div>';
                }
            }
            ?>
        </div>
    </div>
</body>
</html>
