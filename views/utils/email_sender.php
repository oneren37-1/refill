<?php
function sendEmail($to, $m) {
    $subject = 'Информация о заказе';
    $headers = 'From: evil-viktch@yandex.ru' . "\r\n" .
        'X-Mailer: PHP/' . phpversion();

    $boundary = md5(time());
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: multipart/mixed; boundary=\"$boundary\"\r\n";
    $message = "--$boundary\r\n";
    $message .= "Content-Type: text/plain; charset=\"utf-8\"\r\n";
    $message .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
    $message .= $m;
    $message .= "\r\n\r\n--$boundary\r\n";

    mail($to, $subject, $message, $headers);
}