<?php
global $conn;

include(dirname(__DIR__) . '/utils/email_sender.php');

if($_SERVER["REQUEST_METHOD"] == "POST") {
    if (isset($_POST["location"])){
        $stmt = $conn->prepare("call create_order (:user, :location, :fuel, :amount)");
        $stmt->bindParam(':user', $_SESSION["user_uid"]);
        $stmt->bindParam(':location', $_POST["location"]);
        $stmt->bindParam(':fuel', $_POST["fuelType"]);
        $stmt->bindParam(':amount', $_POST["amount"]);

        if ($stmt->execute()) {
            $message = "Уважаемый " . $_SESSION["user_login"] . ", новый заказ сформирован \n\n";
            $message .= "Тип топлива - " . $_POST["fuelType"] . "\n";
            $message .= "Количество топлива - " . $_POST["amount"] . "\n";
            $message .= "Указаннная локация - " . $_POST["location"] . "\n\n";

            sendEmail($_SESSION["user_email"], $message);

            echo "<meta http-equiv='refresh' content='0'>";
        } else {
            echo "Произошла ошибка при выполнении запроса!";
        }
    }
}

$stmt = $conn->prepare("SELECT * FROM fuel");
$stmt->execute();

$fuel = [];
while ($row = $stmt->fetch()) {
    array_push($fuel, $row);
}
?>


<!-- Modal -->
<div class="modal fade" id="addStationModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">Заказ топлива</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" enctype="multipart/form-data">
                <div class="modal-body">
                    <div class="form-group mt-2">
                        <label for="fuelType">Тип топлива</label>

                        <select class="form-select" name="fuelType">
                            <?php foreach ($fuel as $f): ?>
                                <option
                                    <?php if ($f["fid"] == 1) { echo("selected"); }?>
                                        value="<?php echo($f["fid"])?>">
                                    <?php echo($f["name"])?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group mt-2">
                        <label for="amount">Количество (в литрах)</label>
                        <input type="number" class="form-control" id="amount" name="amount" min="1" required>
                    </div>
                    <div class="form-group mt-2">
                        <label for="location">Локация</label>
                        <input type="text" class="form-control" id="location" name="location" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Отменить</button>
                    <button type="submit" class="btn btn-primary">Добавить</button>
                </div>
            </form>
        </div>
    </div>
</div>