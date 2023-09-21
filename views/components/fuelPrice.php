<?php
global $conn;

if($_SERVER["REQUEST_METHOD"] == "POST") {
    if(isset($_POST['fuel_name']) && isset($_POST['fuel_name'])){
        $fuelName = $_POST['fuel_name'];
        $fuelPrice = $_POST['fuel_price'];

        $stmt = $conn->prepare("call update_fuel(:name, :price)");
        $stmt->bindParam(':name', $fuelName);
        $stmt->bindParam(':price', $fuelPrice);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
    }
}

$stmt = $conn->prepare("SELECT * FROM fuel");
$stmt->execute();

$price = [];
while ($row = $stmt->fetch()) {
    array_push($price, $row);
}

?>

<div class="container">
    <h1>Цены на топливо</h1>
    <table class="table table-bordered">
        <thead>
        <tr>
            <th>Тип топлива</th>
            <th>Цена за литр</th>
        </tr>
        </thead>
        <tbody>
        <?php foreach ($price as $p): ?>
            <tr>
                <td><?php echo($p["name"]) ?></td>
                <td>
                    <?php echo($p["price"]) ?> руб
                    <?php if (isset($_SESSION['user_login']) && $_SESSION['user_role'] == 2): ?>
                        <button type="button" class="btn btn-secondary ml-3" data-bs-toggle="modal" data-bs-target="#fuelEdit<?php echo($p["name"]) ?>">Редактировать</button>

                        <div class="modal fade" id="fuelEdit<?php echo($p["name"]) ?>" tabindex="-1" aria-labelledby="fuelEdit<?php echo($p["name"]) ?>" aria-hidden="true">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <form method="post" enctype="multipart/form-data">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Редактирование цены на <?php echo($p["name"]) ?></h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="mb-3">
                                                <label for="recipient-title" class="col-form-label">Цена</label>
                                                <input type="number" step="0.01" required name="fuel_price" class="form-control" value="<?php echo($p["price"]) ?>">
                                            </div>
                                            <input type="text" hidden="" name="fuel_name" class="form-control" value="<?php echo($p["name"]) ?>">
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                            <button type="submit" class="btn btn-primary">Save changes</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    <?php endif;?>
                </td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
</div>

