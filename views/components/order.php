<?php
global $conn;

include(dirname(__DIR__) . '/utils/email_sender.php');

$stmt = $conn->prepare("SELECT * FROM fuel");
$stmt->execute();

$fuel = [];
while ($row = $stmt->fetch()) {
    array_push($fuel, $row);
}

if($_SERVER["REQUEST_METHOD"] == "POST") {
    if (isset($_POST["location"])){
        $fuel = [];
        for ($i = 0; $i < count($_POST["fuel"]); $i++) {
            $f = [
                'fuel' => $_POST["fuel"][$i],
                'amount' => $_POST["amount"][$i]
            ];
            $fuel[] = $f;
        }

        $fuelParam = json_encode($fuel);

        $stmt = $conn->prepare("call create_order (:user, :location, :fuel)");
        $stmt->bindParam(':user', $_SESSION["user_uid"]);
        $stmt->bindParam(':location', $_POST["location"]);
        $stmt->bindParam(':fuel', $fuelParam);

        $f = ['92', '95', '98', '100', 'ДТ', 'Газ'];

        if ($stmt->execute()) {
            $message = "Уважаемый " . $_SESSION["user_login"] . ", новый заказ сформирован \n\n";
            $message .= "Указаннная локация - " . $_POST["location"] . "\n\n";
            $message .= "----------\n";

            for ($i = 0; $i < count($_POST["fuel"]); $i++) {
                $message .= "Топливо - " . $f[$_POST["fuel"][$i]-1] . "\n";
                $message .= "Кол-во  - " . $_POST["amount"][$i] . "\n";
                $message .= "----------\n";
            }

            sendEmail($_SESSION["user_email"], $message);

            echo "<meta http-equiv='refresh' content='0'>";
        } else {
            echo "Произошла ошибка при выполнении запроса!";
        }
    }
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
                        <label for="location">Локация</label>
                        <input type="text" class="form-control" id="location" name="location" required>
                    </div>

                    <div id="fuelFields">
                        <div class="row mb-3 mt-3">
                            <div class="col col-md-4">
                                <select class="form-select" name="fuel[]">
                                    <?php foreach ($fuel as $f): ?>
                                        <option
                                            <?php if ($f["fid"] == 1) { echo("selected"); }?>
                                                value="<?php echo($f["fid"])?>">
                                            <?php echo($f["name"])?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            <div class="col col-md-4">
                                <input type="number" class="form-control" name="amount[]" placeholder="Amount" value=1 min=1>
                            </div>
                        </div>
                    </div>
                    <button type="button" class="btn btn-primary" onclick="addFuelField()">Еще топливо</button>

                    <script>
                        function addFuelField() {
                            var fuelFields = document.getElementById("fuelFields");
                            var newField = document.createElement("div");
                            newField.classList.add("form-row", "col-xs-6");
                            newField.innerHTML = `
                            <div class="row mb-3">
                                <div class="col col-md-4">
                                    <select class="form-select" name="fuel[]">
                                        <?php foreach ($fuel as $f): ?>
                                            <option
                                                <?php if ($f["fid"] == 1) { echo("selected"); }?>
                                                    value="<?php echo($f["fid"])?>">
                                                <?php echo($f["name"])?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col col-md-4">
                                    <input type="number" class="form-control" name="amount[]" placeholder="Amount" value=1 min=1>
                                </div>
                            </div>
                            `;
                            fuelFields.appendChild(newField);
                        }
                    </script>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Отменить</button>
                    <button type="submit" class="btn btn-primary">Добавить</button>
                </div>
            </form>
        </div>
    </div>
</div>