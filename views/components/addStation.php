<?php
global $conn;

if($_SERVER["REQUEST_METHOD"] == "POST") {
    $img = null;
    //Проверяем, было ли загружено изображение
    if(isset($_FILES['img']) && $_FILES['img']['error'] === UPLOAD_ERR_OK) {
        //Получаем информацию о файле
        $file_name = $_FILES['img']['name'];
        $file_tmp = $_FILES['img']['tmp_name'];
        $file_size = $_FILES['img']['size'];
        $file_error = $_FILES['img']['error'];
        $file_type = $_FILES['img']['type'];
        //Проверяем расширение файла
        if($file_type === 'image/jpg' || $file_type === 'image/jpeg' || $file_type === 'image/png') {
            //Задаем путь для сохранения файла
            $target_dir = "D:\D\Documents\ptu\web\OSPanel\domains\localhost\\refill\uploads\\";
            $time = time();
            $target_file = $target_dir . $time . basename($file_name);
            //Перемещаем файл в нужную директорию
            if(move_uploaded_file($file_tmp, $target_file)) {
                $img = "/refill/uploads/". $time . basename($file_name);
            } else {
                echo "Произошла ошибка при сохранении файла.";
            }
        } else {
            echo "Допустимы только файлы JPEG, PNG и JPG.";
        }

        $stmt = $conn->prepare("call create_station (:img, :location, :description)");
        $stmt->bindParam(':location', $_POST["location"]);
        $stmt->bindParam(':img', $img);
        $stmt->bindParam(':description', $_POST["desc"]);

        if ($stmt->execute()) {
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
                <h5 class="modal-title" id="exampleModalLabel">Новая заправка</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" enctype="multipart/form-data">
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="recipient-title" class="col-form-label">Прикрепите картинку</label>
                        <input type="file" name="img" accept=".png, .jpg" class="form-control" id="recipient-title">
                    </div>
                    <div class="mb-3">
                        <label for="recipient-location" class="col-form-label">Адрес</label>
                        <input type="text" required name="location" class="form-control" id="recipient-location">
                    </div>
                    <div class="mb-3">
                        <label for="recipient-desc" class="col-form-label">Описание</label>
                        <textarea class="form-control" name="desc" id="recipient-desc" rows="10"></textarea>
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