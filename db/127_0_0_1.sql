-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Сен 20 2023 г., 15:37
-- Версия сервера: 8.0.30
-- Версия PHP: 8.1.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `refill`
--

DELIMITER $$
--
-- Процедуры
--
DROP PROCEDURE IF EXISTS `create_order`$$
CREATE PROCEDURE `create_order` (IN `u` INT, IN `l` TEXT, IN `ft` INT, IN `a` INT)   BEGIN
    insert into `order` (user, location, fuel_type, amount, price)
    values (u, l, ft, a, (select price*a from fuel where fid=ft));
END$$

DROP PROCEDURE IF EXISTS `create_station`$$
CREATE PROCEDURE `create_station` (IN `i` TEXT, IN `loc` TEXT, IN `d` TEXT)   BEGIN
    insert into station (img, location, description)
    values (i, loc, d);
END$$

DROP PROCEDURE IF EXISTS `create_user`$$
CREATE PROCEDURE `create_user` (IN `l` TEXT, IN `p` TEXT, IN `e` TEXT)   BEGIN
    insert into user (login, password, email)
    values (l, p, e);
END$$

DROP PROCEDURE IF EXISTS `update_fuel`$$
CREATE PROCEDURE `update_fuel` (IN `n` TEXT, IN `p` DOUBLE)   BEGIN
    UPDATE fuel
    SET price = p
    WHERE name=n;
END$$

DROP PROCEDURE IF EXISTS `update_order_status`$$
CREATE PROCEDURE `update_order_status` (IN `id` INT, IN `s` INT)   BEGIN
    UPDATE `order`
    SET status=s
    WHERE oid=id;
END$$

--
-- Функции
--
DROP FUNCTION IF EXISTS `count_unfinished_orders`$$
CREATE FUNCTION `count_unfinished_orders` () RETURNS INT  BEGIN
    DECLARE count INT DEFAULT 0;
    SELECT COUNT(*) INTO count FROM refill.`order` WHERE status <> 3 and status <> 4;
    RETURN count;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `comment`
--

DROP TABLE IF EXISTS `comment`;
CREATE TABLE IF NOT EXISTS `comment` (
  `sid` int NOT NULL AUTO_INCREMENT,
  `station` int NOT NULL,
  `user` int NOT NULL,
  `message` text NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sid`),
  KEY `comment_station_sid_fk` (`station`),
  KEY `comment_user_uid_fk` (`user`)
) ;

--
-- Очистить таблицу перед добавлением данных `comment`
--

TRUNCATE TABLE `comment`;
--
-- Дамп данных таблицы `comment`
--

INSERT INTO `comment` (`sid`, `station`, `user`, `message`, `date`) VALUES
(7, 2, 1, 'Комментарий', '2023-09-20 14:50:34'),
(8, 5, 7, 'лайк', '2023-09-20 14:52:00');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `comments`
-- (См. Ниже фактическое представление)
--
DROP VIEW IF EXISTS `comments`;
CREATE TABLE IF NOT EXISTS `comments` (
`date` datetime
,`login` text
,`message` text
,`sid` int
,`station` int
);

-- --------------------------------------------------------

--
-- Структура таблицы `fuel`
--

DROP TABLE IF EXISTS `fuel`;
CREATE TABLE IF NOT EXISTS `fuel` (
  `fid` int NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  `price` double NOT NULL,
  PRIMARY KEY (`fid`)
);

--
-- Очистить таблицу перед добавлением данных `fuel`
--

TRUNCATE TABLE `fuel`;
--
-- Дамп данных таблицы `fuel`
--

INSERT INTO `fuel` (`fid`, `name`, `price`) VALUES
(1, '92', 51.03),
(2, '95', 55),
(3, '98', 66.52),
(4, '100', 69.69),
(5, 'ДТ', 63.29),
(6, 'Газ', 28.09);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `graph`
-- (См. Ниже фактическое представление)
--
DROP VIEW IF EXISTS `graph`;
CREATE TABLE IF NOT EXISTS `graph` (
`c` bigint
,`fuel` text
);

-- --------------------------------------------------------

--
-- Структура таблицы `order`
--

DROP TABLE IF EXISTS `order`;
CREATE TABLE IF NOT EXISTS `order` (
  `oid` int NOT NULL AUTO_INCREMENT,
  `user` int NOT NULL,
  `location` text NOT NULL,
  `fuel_type` int NOT NULL,
  `amount` int NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `delivery_date` datetime DEFAULT NULL,
  `price` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`oid`),
  KEY `order_fuel_fid_fk` (`fuel_type`),
  KEY `order_user_uid_fk` (`user`),
  KEY `order_order_status_sid_fk` (`status`)
) ;

--
-- Очистить таблицу перед добавлением данных `order`
--

TRUNCATE TABLE `order`;
--
-- Дамп данных таблицы `order`
--

INSERT INTO `order` (`oid`, `user`, `location`, `fuel_type`, `amount`, `status`, `creation_date`, `delivery_date`, `price`) VALUES
(1, 6, 'saint-petersburg', 1, 1, 1, '2023-09-20 00:00:00', NULL, 0),
(2, 6, 'Макаренко 15', 1, 2, 1, '2023-09-20 00:00:00', NULL, 0),
(3, 6, 'Макаренко 15', 1, 2, 1, '2023-09-20 00:00:00', NULL, 0),
(4, 6, 'saint-petersburg', 3, 1, 1, '2023-09-20 00:00:00', NULL, 100),
(5, 6, 'saint-petersburg', 1, 1, 1, '2023-09-20 00:00:00', NULL, 100),
(6, 6, 'Макаренко 15', 6, 2, 1, '2023-09-20 00:00:00', NULL, 200),
(7, 6, 'saint-petersburg', 5, 4, 1, '2023-09-20 00:00:00', NULL, 63.29),
(8, 6, 'Макаренко 15', 3, 1, 1, '2023-09-20 00:00:00', NULL, 66.52),
(9, 7, 'www', 1, 2, 3, '2023-09-20 00:00:00', NULL, 51.03),
(10, 7, 'skjsadk', 1, 10, 4, '2023-09-20 00:00:00', NULL, 51.03),
(11, 7, 'Макаренко 15', 1, 19, 4, '2023-09-20 00:00:00', NULL, 969.57),
(12, 7, 'eeee', 6, 2, 4, '2023-09-20 00:00:00', NULL, 56.18),
(13, 7, 'eeee', 2, 3, 4, '2023-09-20 00:00:00', NULL, 165);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `orders`
-- (См. Ниже фактическое представление)
--
DROP VIEW IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
`amount` int
,`creation_date` datetime
,`delivery_date` datetime
,`fuel_type` text
,`location` text
,`login` text
,`oid` int
,`price` double
,`status` text
,`uid` int
,`user` int
);

-- --------------------------------------------------------

--
-- Структура таблицы `order_status`
--

DROP TABLE IF EXISTS `order_status`;
CREATE TABLE IF NOT EXISTS `order_status` (
  `sid` int NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  PRIMARY KEY (`sid`)
);

--
-- Очистить таблицу перед добавлением данных `order_status`
--

TRUNCATE TABLE `order_status`;
--
-- Дамп данных таблицы `order_status`
--

INSERT INTO `order_status` (`sid`, `name`) VALUES
(1, 'В обработке'),
(2, 'В пути'),
(3, 'Вручен'),
(4, 'Отменен');

-- --------------------------------------------------------

--
-- Структура таблицы `role`
--

DROP TABLE IF EXISTS `role`;
CREATE TABLE IF NOT EXISTS `role` (
  `rid` int NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  PRIMARY KEY (`rid`)
);

--
-- Очистить таблицу перед добавлением данных `role`
--

TRUNCATE TABLE `role`;
--
-- Дамп данных таблицы `role`
--

INSERT INTO `role` (`rid`, `name`) VALUES
(1, 'user'),
(2, 'administrator');

-- --------------------------------------------------------

--
-- Структура таблицы `station`
--

DROP TABLE IF EXISTS `station`;
CREATE TABLE IF NOT EXISTS `station` (
  `sid` int NOT NULL AUTO_INCREMENT,
  `location` text NOT NULL,
  `description` longtext,
  `img` text NOT NULL,
  PRIMARY KEY (`sid`)
);

--
-- Очистить таблицу перед добавлением данных `station`
--

TRUNCATE TABLE `station`;
--
-- Дамп данных таблицы `station`
--

INSERT INTO `station` (`sid`, `location`, `description`, `img`) VALUES
(1, 'Лиговский 34', 'Добро пожаловать на Автозаправочную станцию \"Зеленая Энергия\"\n\nНаши АЗС предоставляют высококачественное топливо, быстрое обслуживание и удобные условия для заправки. Мы заботимся о окружающей среде и предлагаем экологичные виды топлива.\n\nРаботаем для вас 24/7!', 'https://www.rosneft-azs.ru/media/frontend/img/IMG_9238.jpg'),
(2, 'Комсомольская 5', 'Топливо и сервис на высшем уровне\n\nНаши АЗС - это надежное место для заправки вашего автомобиля. Мы предлагаем широкий выбор топлива, включая бензин и дизельное топливо, обеспечивая его высокое качество и безопасность. Наши современные насосы и системы обслуживания гарантируют быструю и эффективную заправку, сохраняя ваше драгоценное время.\n\nЭкологически ответственные решения\n\nМы ценим окружающую среду и предоставляем возможность заправки альтернативных видов топлива, таких как электричество и сжиженный природный газ (СПГ). Это позволяет вам снизить воздействие на климат и сэкономить на затратах.\n\nУдобство и комфорт\n\nНаши АЗС обеспечивают комфортные условия для вас и вашей машины. Просторные автозаправочные острова и зоны отдыха позволяют вам расслабиться и подкрепиться перед долгой дорогой.', 'https://cdnn21.img.ria.ru/images/07e6/06/0e/1795240662_0:321:3071:2048_1920x0_80_0_0_b00d37de8e45a09932723170167e55ec.jpg'),
(3, 'saint-petersburg', '123', '/refill/uploads/1695192951270234.jpg'),
(4, 'saint-petersburg', '11', '/refill/uploads/1695192964270234.jpg'),
(5, 'Макаренко 15', '', '/refill/uploads/16951929865042.jpg'),
(6, 'Комарова 33', 'описание', '/refill/uploads/1695210854270234.jpg');

-- --------------------------------------------------------

--
-- Структура таблицы `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `uid` int NOT NULL AUTO_INCREMENT,
  `login` text NOT NULL,
  `role` int NOT NULL DEFAULT '1',
  `email` text NOT NULL,
  `password` text NOT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `user_u` (`login`(255)),
  KEY `user_role_rid_fk` (`role`)
);

--
-- Очистить таблицу перед добавлением данных `user`
--

TRUNCATE TABLE `user`;
--
-- Дамп данных таблицы `user`
--

INSERT INTO `user` (`uid`, `login`, `role`, `email`, `password`) VALUES
(1, 'admin', 2, 'oneren37@gmail.com', 'admin'),
(2, 'qwe', 1, 'some@gmail.com', 'qwe'),
(3, 'qwe1', 1, 'sdvdfv@sdvdv', 'qwe'),
(6, 'qwe2', 1, 'sdvdfv@sdvdv', '123'),
(7, 'q', 1, 'sdvdfv@sdvdv', '123');

-- --------------------------------------------------------

--
-- Структура для представления `comments`
--
DROP TABLE IF EXISTS `comments`;

DROP VIEW IF EXISTS `comments`;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `comments`  AS SELECT `u`.`login` AS `login`, `comment`.`station` AS `station`, `comment`.`sid` AS `sid`, `comment`.`message` AS `message`, `comment`.`date` AS `date` FROM (`comment` join `user` `u` on((`comment`.`user` = `u`.`uid`)))  ;

-- --------------------------------------------------------

--
-- Структура для представления `graph`
--
DROP TABLE IF EXISTS `graph`;

DROP VIEW IF EXISTS `graph`;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `graph`  AS SELECT `f`.`name` AS `fuel`, count(`f`.`name`) AS `c` FROM (`order` join `fuel` `f` on((`f`.`fid` = `order`.`fuel_type`))) GROUP BY `f`.`name`;

-- --------------------------------------------------------

--
-- Структура для представления `orders`
--
DROP TABLE IF EXISTS `orders`;

DROP VIEW IF EXISTS `orders`;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `orders`  AS SELECT `order`.`oid` AS `oid`, `order`.`user` AS `user`, `f`.`name` AS `fuel_type`, `user`.`uid` AS `uid`, `user`.`login` AS `login`, `order`.`amount` AS `amount`, `order`.`price` AS `price`, `order`.`location` AS `location`, `os`.`name` AS `status`, `order`.`creation_date` AS `creation_date`, `order`.`delivery_date` AS `delivery_date` FROM (((`order` join `fuel` `f` on((`f`.`fid` = `order`.`fuel_type`))) join `order_status` `os` on((`os`.`sid` = `order`.`status`))) join `user` on((`user`.`uid` = `order`.`user`))) ORDER BY `order`.`creation_date` ASC  ;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `comment`
--
ALTER TABLE `comment`
  ADD CONSTRAINT `comment_station_sid_fk` FOREIGN KEY (`station`) REFERENCES `station` (`sid`),
  ADD CONSTRAINT `comment_user_uid_fk` FOREIGN KEY (`user`) REFERENCES `user` (`uid`);

--
-- Ограничения внешнего ключа таблицы `order`
--
ALTER TABLE `order`
  ADD CONSTRAINT `order_fuel_fid_fk` FOREIGN KEY (`fuel_type`) REFERENCES `fuel` (`fid`),
  ADD CONSTRAINT `order_order_status_sid_fk` FOREIGN KEY (`status`) REFERENCES `order_status` (`sid`),
  ADD CONSTRAINT `order_user_uid_fk` FOREIGN KEY (`user`) REFERENCES `user` (`uid`);

--
-- Ограничения внешнего ключа таблицы `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_role_rid_fk` FOREIGN KEY (`role`) REFERENCES `role` (`rid`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
