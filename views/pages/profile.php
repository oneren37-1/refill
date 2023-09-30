<?php

global $conn;
require(dirname(__DIR__).'/utils/db_connection.php');
require(dirname(__DIR__) . '/utils/email_sender.php');
session_start();

if ($_SESSION["user_role"] == 2) {
    $query = "select * from user where role = 3";

    $stmt = $conn->prepare($query);
    $stmt->execute();

    $dm = [];
    while ($row = $stmt->fetch()) {
        array_push($dm, $row);
    }
}

if($_SERVER["REQUEST_METHOD"] == "POST") {
    if(isset($_POST['update_order_id']) && isset($_POST['update_order_status'])){
        $oid = $_POST['update_order_id'];
        $status = $_POST['update_order_status'];

        $stmt = $conn->prepare("call update_order_status(:oid, :s)");
        $stmt->bindParam(':oid', $oid);
        $stmt->bindParam(':s', $status);

        if ($stmt->execute()) {
            if ($_POST['update_order_status'] == 3) {
                $stmt = $conn->prepare("UPDATE `order` SET delivery_date=current_timestamp WHERE oid=:oid;");
                $stmt->bindParam(':oid', $oid);
                $stmt->execute();
            }

            if ($_POST['update_order_status'] == 2 && isset($_POST['delivery_man'])) {
                $delivery_man = $_POST['delivery_man'];

                $stmt = $conn->prepare("UPDATE `order` SET delivery_man=:dm WHERE oid=:oid;");
                $stmt->bindParam(':oid', $oid);
                $stmt->bindParam(':dm', $delivery_man);
                $stmt->execute();

                $dmLogin = "";
                $dmCar = "";
                for ($j = 0; $j < count($dm); $j++) {
                    if ($dm[$j]["uid"] == $delivery_man) {
                        $dmLogin = $dm[$j]["login"];
                        $dmCar = $dm[$j]["car"];
                        break;
                    }
                }

                $message = "На ваш заказ №".$oid." назначен водитель \n\n";
                $message .= $dmLogin." приедет на машине ".$dmCar." \n\n";

                sendEmail($_SESSION["user_email"], $message);
            }
            echo "<meta http-equiv='refresh' content='0'>";
        } else {
            echo "Произошла ошибка при выполнении запроса!";
        }
    }
}

$query = "SELECT * FROM orders WHERE uid=:uid order by oid desc";
if ($_SESSION["user_role"] == 2) {
    $query = "SELECT * FROM orders order by oid desc";
}
if ($_SESSION["user_role"] == 3) {
    $query = "SELECT * FROM orders where dm_uid=:uid order by oid desc";
}

$stmt = $conn->prepare($query);
if ($_SESSION["user_role"] != 2) {
    $stmt->bindParam(":uid", $_SESSION["user_uid"]);
}
$stmt->execute();

$orders = [];
while ($row = $stmt->fetch()) {
    array_push($orders, $row);
}

$graph = [];
if ($_SESSION["user_role"] == 2) {
    $stmt = $conn->prepare("SELECT * FROM graph");
    $stmt->execute();
    while ($row = $stmt->fetch()) {
        array_push($graph, $row);
    }
}

$stmt = $conn->prepare("SELECT count_unfinished_orders() as c;");
$stmt->execute();

$unfinished_count = 0;
while ($row = $stmt->fetch()) {
    $unfinished_count = $row["c"];
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

    <?php if (isset($_SESSION["user_role"]) && $_SESSION["user_role"] == 2): ?>
        <!--Load the AJAX API-->
        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
        <script type="text/javascript">

            google.charts.load('current', {'packages':['corechart']});

            google.charts.setOnLoadCallback(drawChart);
            function drawChart() {

                var data = new google.visualization.DataTable();
                data.addColumn('string', 'Topping');
                data.addColumn('number', 'Slices');
                data.addRows([
                    <?php foreach ($graph as $g): ?>
                    ['<?php echo($g["fuel"]) ?>', <?php echo($g["c"]) ?>],
                    <?php endforeach; ?>
                ]);

                var options = {'title':'Соотношение числа заказов по типам топлива',
                    'width':600,
                    'height':500};

                var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
                chart.draw(data, options);
            }
        </script>
    <?php endif; ?>

</head>
<body>
    <?php include(dirname(__DIR__).'/components/header.php');?>
    <div class="page-wrapper">
        <h1><?php echo($_SESSION["user_login"])?></h1>
        <hr/>
        <?php if ($_SESSION["user_role"] == 1): ?>
            <!-- Button trigger modal -->
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addStationModal">
                Заказать топливо
            </button>
            <?php include(dirname(__DIR__).'/components/order.php');?>
            <hr/>
        <?php endif; ?>

        <?php if ($_SESSION["user_role"] == 2): ?>
            <p>Осталось незакрытых заказов: <?php echo($unfinished_count)?></p>
            <div id="chart_div"></div>
        <?php endif; ?>

        <?php foreach ($orders as $order): ?>
            <div class="container">
                <div class="card p-3 m-3">
                    <div class="order-card">
                        <h4>Заказ №<?php echo($order["oid"])?></h4>
                        <p><strong>Статус заказа:</strong> <?php echo($order["status"])?></p>
                        <?php if ($_SESSION["user_role"] == 2): ?>
                            <p><strong>Заказчик:</strong> <?php echo($order["login"])?></p>
                        <?php endif; ?>
                        <table class="table table-bordered">
                            <thead>
                                <tr><th>Топливо</th><th>Количество</th></tr>
                            </thead>
                            <tbody>
                                <?php
                                    $data = json_decode($order["fuel"], true);

                                    foreach ($data as $item) {
                                        echo '<tr>';
                                        echo '<td>' . $item['fuel'] . '</td>';
                                        echo '<td>' . $item['amount'] . '</td>';
                                        echo '</tr>';
                                    }
                                ?>
                            </tbody>
                        </table>

                        <p><strong>Цена:</strong> <?php echo($order["price"])?></p>
                        <p><strong>Дата формирования заказа:</strong> <?php echo($order["creation_date"])?></p>
                        <?php if ($order["dm_login"] != "") : ?>
                            <p><strong>Назначенный доставщик: </strong> <?php echo($order["dm_login"])?>
                                <?php if ($order["dm_car"] != "") : ?>
                                    <strong>на машине</strong> <?php echo($order["dm_car"])?>
                                <?php endif; ?>
                            </p>
                        <?php endif; ?>
                        <?php if ($order["delivery_date"] != "") : ?>
                            <p><strong>Дата доставки заказа:</strong> <?php echo($order["delivery_date"])?></p>
                        <?php endif; ?>
                        <?php if ($order["status"] != "Отменен" && $order["status"] != "Вручен"): ?>
                            <form method="post" enctype="multipart/form-data" class="mb-2">
                                <input type="text" hidden name="update_order_id" value="<?php echo($order["oid"])?>">
                                <input type="number" hidden name="update_order_status" value="4">
                                <button type="submit" class="btn btn-secondary">Отменить</button>
                            </form>
                        <?php endif; ?>

                        <?php if ($_SESSION["user_role"] == 2 && $order["status"] == "В обработке"): ?>
                            <form method="post" enctype="multipart/form-data">
                                <input type="text" hidden name="update_order_id" value="<?php echo($order["oid"])?>">
                                <input type="number" hidden name="update_order_status" value="2">

                                <p>Выберите доставщика</p>
                                <select class="form-select mb-2" name="delivery_man">
                                    <?php foreach ($dm as $m): ?>
                                        <option
                                            <?php if ($m["uid"] == 10) { echo("selected"); }?>
                                                value="<?php echo($m["uid"])?>">
                                            <?php echo($m["login"])?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                                <button type="submit" class="btn btn-primary">Отправить заказ</button>
                            </form>
                        <?php endif; ?>

                        <?php if (($_SESSION["user_role"] == 2 || $_SESSION["user_role"] == 3) && $order["status"] == "В пути"): ?>
                            <form method="post" enctype="multipart/form-data">
                                <input type="text" hidden name="update_order_id" value="<?php echo($order["oid"])?>">
                                <input type="number" hidden name="update_order_status" value="3">
                                <button type="submit" class="btn btn-primary">Пометить как врученный</button>
                            </form>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    </div>
</body>
</html>
