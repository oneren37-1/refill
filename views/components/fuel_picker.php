<div class="container mt-5">
    <h1>Выбор типа топлива</h1>
    <form>
        <div class="form-group">
            <label for="vehicleType">Выберите тип транспорта:</label>
            <select class="form-control" id="vehicleType">
                <option value="грузовая">Грузовая</option>
                <option value="легковая">Легковая</option>
            </select>
        </div>

        <div class="form-group" id="compressionRatioDiv" style="display: none;">
            <label for="compressionRatio">Выберите степень сжатия в цилиндро-поршневой группе:</label>
            <select class="form-control" id="compressionRatio">
                <option value="меньше10.5">Меньше 10.5</option>
                <option value="меньше12">Меньше 12</option>
                <option value="больше12">Больше 12</option>
            </select>
        </div>

        <div class="form-group">
            <p id="result"></p>
        </div>

        <button type="button" class="btn btn-primary" id="calculate">Рассчитать</button>
    </form>
</div>

<!-- Подключаем Bootstrap и jQuery JavaScript -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

<script>
    // Обработчик события для кнопки "Рассчитать"
    document.getElementById("calculate").addEventListener("click", function () {
        var vehicleType = document.getElementById("vehicleType").value;
        var compressionRatio = document.getElementById("compressionRatio").value;
        var result = document.getElementById("result");

        if (vehicleType === "грузовая") {
            result.textContent = "Нужен дизель";
        } else if (vehicleType === "легковая") {
            if (compressionRatio === "меньше10.5") {
                result.textContent = "Выберите бензин 92";
            } else if (compressionRatio === "меньше12") {
                result.textContent = "Выберите бензин 95";
            } else if (compressionRatio === "больше12") {
                result.textContent = "Выберите бензин 98";
            }
        }
    });

    // Показываем или скрываем список степеней сжатия при выборе типа транспорта
    document.getElementById("vehicleType").addEventListener("change", function () {
        var compressionRatioDiv = document.getElementById("compressionRatioDiv");
        if (this.value === "легковая") {
            compressionRatioDiv.style.display = "block";
        } else {
            compressionRatioDiv.style.display = "none";
        }
    });
</script>