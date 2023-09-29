-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Сен 29 2023 г., 05:11
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
CREATE PROCEDURE `create_order` (IN `u` INT, IN `l` TEXT, IN `f` TEXT)   BEGIN
    insert into `order` (user, location, price)
    values (u, l, (
        select sum(val) from (
                 select fuel.price*amount as val
                 from JSON_TABLE(f, '$[*]'
                                 COLUMNS (
                                     fuel VARCHAR(255) PATH '$.fuel',
                                     amount INT PATH '$.amount'
                                     )
                          ) AS jt join fuel on jt.fuel = fuel.fid
             ) t
        )
    );

    INSERT INTO order_fuel (`order`, fuel_type, amount)
    SELECT ord.o, jt.fuel, jt.amount
    FROM JSON_TABLE(f, '$[*]'
         COLUMNS (
             fuel VARCHAR(255) PATH '$.fuel',
             amount INT PATH '$.amount'
             )
     ) AS jt cross join (
         select max(oid) o from `order`
    ) ord;
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
    SELECT COUNT(*) INTO count FROM refill.`orders` WHERE status <> 'Вручен' and status <> 'Отменен';
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
(8, 5, 7, 'лайк', '2023-09-20 14:52:00'),
(9, 1, 1, '1111', '2023-09-20 15:42:12');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `comments`
-- (См. Ниже фактическое представление)
--
DROP VIEW IF EXISTS `comments`;
CREATE TABLE IF NOT EXISTS `comments` (
`login` text
,`station` int
,`sid` int
,`message` text
,`date` datetime
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
`fuel` text
,`c` decimal(32,0)
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
  `status` int NOT NULL DEFAULT '1',
  `creation_date` datetime NOT NULL DEFAULT (now()),
  `delivery_date` datetime DEFAULT NULL,
  `price` double NOT NULL DEFAULT '0',
  `delivery_man` int DEFAULT NULL,
  PRIMARY KEY (`oid`),
  KEY `order_user_uid_fk` (`user`),
  KEY `order_order_status_sid_fk` (`status`),
  KEY `order_user_uid_fk2` (`delivery_man`)
);

--
-- Очистить таблицу перед добавлением данных `order`
--

TRUNCATE TABLE `order`;
--
-- Дамп данных таблицы `order`
--

INSERT INTO `order` (`oid`, `user`, `location`, `status`, `creation_date`, `delivery_date`, `price`, `delivery_man`) VALUES
(1, 6, 'saint-petersburg', 1, '2023-09-20 00:00:00', NULL, 0, NULL),
(2, 6, 'Макаренко 15', 1, '2023-09-20 00:00:00', NULL, 0, NULL),
(3, 6, 'Макаренко 15', 1, '2023-09-20 00:00:00', NULL, 0, NULL),
(4, 6, 'saint-petersburg', 1, '2023-09-20 00:00:00', NULL, 100, NULL),
(5, 6, 'saint-petersburg', 1, '2023-09-20 00:00:00', NULL, 100, NULL),
(6, 6, 'Макаренко 15', 1, '2023-09-20 00:00:00', NULL, 200, NULL),
(7, 6, 'saint-petersburg', 1, '2023-09-20 00:00:00', NULL, 63.29, NULL),
(8, 6, 'Макаренко 15', 1, '2023-09-20 00:00:00', NULL, 66.52, NULL),
(9, 7, 'www', 3, '2023-09-20 00:00:00', NULL, 51.03, NULL),
(10, 7, 'skjsadk', 4, '2023-09-20 00:00:00', NULL, 51.03, NULL),
(11, 7, 'Макаренко 15', 4, '2023-09-20 00:00:00', NULL, 969.57, NULL),
(12, 7, 'eeee', 4, '2023-09-20 00:00:00', NULL, 56.18, NULL),
(13, 7, 'eeee', 4, '2023-09-20 00:00:00', NULL, 165, NULL),
(14, 7, '111', 1, '2023-09-21 18:51:02', NULL, 102.06, NULL),
(15, 7, 'sdc', 1, '2023-09-21 18:51:28', NULL, 153.09, NULL),
(16, 7, 'ddfdfdfv', 3, '2023-09-21 18:52:33', '2023-09-22 13:37:22', 51.03, NULL),
(17, 7, 'Тимерия', 3, '2023-09-21 18:58:09', NULL, 280.9, NULL),
(18, 7, 'Заснеженные пики Кавказских гор', 3, '2023-09-21 19:00:42', '2023-09-29 01:03:34', 6329, 10),
(19, 8, 'Джунгли амазонки', 3, '2023-09-21 19:02:27', '2023-09-26 03:03:41', 2809, 11),
(22, 8, 'Солнечная калифорния', 1, '2023-09-29 01:28:24', NULL, 0, NULL),
(23, 8, 'Солнечная калифорния', 1, '2023-09-29 01:29:43', NULL, 0, NULL),
(24, 8, 'Солнечная калифорния', 1, '2023-09-29 01:31:19', NULL, 0, NULL),
(25, 8, 'Солнечная калифорния', 1, '2023-09-29 01:35:39', NULL, 2661.5, NULL),
(26, 8, 'Солнечная калифорния', 3, '2023-09-29 01:36:24', '2023-09-29 04:39:46', 51.03, 11),
(27, 8, 'Солнечная калифорния', 2, '2023-09-29 01:36:42', NULL, 51.03, NULL),
(28, 8, 'ул. Зачета д.5', 3, '2023-09-29 02:50:40', NULL, 765.92, NULL),
(29, 8, 'Макаренко 15', 2, '2023-09-29 02:52:34', NULL, 110, NULL),
(30, 8, 'Макаренко 15', 2, '2023-09-29 02:56:59', '2023-09-29 04:39:25', 260.1, 10),
(31, 8, 'saint-petersburg', 2, '2023-09-29 03:05:16', NULL, 767.26, NULL),
(32, 8, 'saint-petersburg', 3, '2023-09-29 03:07:26', NULL, 291.58, NULL),
(33, 8, 'saint-petersburg', 3, '2023-09-29 03:09:09', NULL, 51.03, NULL),
(34, 8, 'saint-petersburg', 3, '2023-09-29 03:15:53', NULL, 177.61, NULL),
(35, 8, 'saint-petersburg', 4, '2023-09-29 04:52:04', '2023-09-29 04:52:59', 513.45, 11),
(36, 8, 'saint-petersburg', 1, '2023-09-29 05:05:17', NULL, 102.06, NULL),
(37, 8, 'saint-petersburg', 4, '2023-09-29 05:05:39', NULL, 250.59, NULL),
(38, 8, 'saint-petersburg', 3, '2023-09-29 05:05:58', '2023-09-29 05:06:31', 266.08, 11);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `orders`
-- (См. Ниже фактическое представление)
--
DROP VIEW IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
`oid` int
,`uid` int
,`login` text
,`price` double
,`location` text
,`status` text
,`creation_date` datetime
,`delivery_date` datetime
,`dm_uid` int
,`dm_login` text
,`dm_car` text
,`fuel` json
);

-- --------------------------------------------------------

--
-- Структура таблицы `order_fuel`
--

DROP TABLE IF EXISTS `order_fuel`;
CREATE TABLE IF NOT EXISTS `order_fuel` (
  `order` int NOT NULL,
  `fuel_type` int NOT NULL,
  `amount` int NOT NULL,
  PRIMARY KEY (`order`,`fuel_type`),
  KEY `order_fuel_fuel_fid_fk` (`fuel_type`)
);

--
-- Очистить таблицу перед добавлением данных `order_fuel`
--

TRUNCATE TABLE `order_fuel`;
--
-- Дамп данных таблицы `order_fuel`
--

INSERT INTO `order_fuel` (`order`, `fuel_type`, `amount`) VALUES
(18, 2, 10),
(19, 1, 100),
(19, 3, 2),
(24, 1, 50),
(24, 2, 2),
(25, 1, 50),
(25, 2, 2),
(26, 1, 1),
(27, 1, 1),
(28, 1, 4),
(28, 6, 20),
(29, 2, 2),
(30, 1, 1),
(30, 4, 3),
(31, 1, 2),
(31, 3, 10),
(32, 2, 3),
(32, 5, 2),
(33, 1, 1),
(34, 1, 1),
(34, 5, 2),
(35, 2, 3),
(35, 4, 5),
(37, 1, 1),
(37, 3, 3),
(38, 3, 4);

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
(2, 'administrator'),
(3, 'delivery_man');

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
(6, 'Комарова 33', 'описание', '/refill/uploads/1695210854270234.jpg'),
(7, '123', '123', '/refill/uploads/16953205915042.jpg');

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
  `car` text,
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

INSERT INTO `user` (`uid`, `login`, `role`, `email`, `password`, `car`) VALUES
(1, 'admin', 2, 'oneren37@gmail.com', 'admin', NULL),
(2, 'qwe', 1, 'some@gmail.com', 'qwe', NULL),
(3, 'qwe1', 1, 'sdvdfv@sdvdv', 'qwe', NULL),
(6, 'qwe2', 1, 'sdvdfv@sdvdv', '123', NULL),
(7, 'q', 1, 'sdvdfv@sdvdv', '123', NULL),
(8, 'oneren', 1, 'oneren37@gmail.com', '123', NULL),
(10, 'petrovich', 3, 'petrovich@gmail.com', '123', 'О 654 ХН'),
(11, 'gena', 3, 'gena@gmail.com', '123', 'Н 920 МУ'),
(12, 'stepanych', 3, 'stepa@gmail.com', '123', 'Н 077 ТЕ');

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
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `graph`  AS SELECT `f`.`name` AS `fuel`, sum(`order_fuel`.`amount`) AS `c` FROM (`order_fuel` join `fuel` `f` on((`f`.`fid` = `order_fuel`.`fuel_type`))) GROUP BY `f`.`fid``fid`  ;

-- --------------------------------------------------------

--
-- Структура для представления `orders`
--
DROP TABLE IF EXISTS `orders`;

DROP VIEW IF EXISTS `orders`;
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `orders`  AS SELECT `t`.`oid` AS `oid`, `t`.`uid` AS `uid`, `t`.`login` AS `login`, `t`.`price` AS `price`, `t`.`location` AS `location`, `t`.`status` AS `status`, `t`.`creation_date` AS `creation_date`, `t`.`delivery_date` AS `delivery_date`, `t`.`dm_uid` AS `dm_uid`, `t`.`dm_login` AS `dm_login`, `t`.`dm_car` AS `dm_car`, `t`.`fuel` AS `fuel` FROM (select `order`.`oid` AS `oid`,`u`.`uid` AS `uid`,`u`.`login` AS `login`,`order`.`price` AS `price`,`order`.`location` AS `location`,`s`.`name` AS `status`,`order`.`creation_date` AS `creation_date`,`order`.`delivery_date` AS `delivery_date`,`d`.`uid` AS `dm_uid`,`d`.`login` AS `dm_login`,`d`.`car` AS `dm_car`,(select json_arrayagg(json_object('fuel',`f3`.`name`,'amount',`order_fuel`.`amount`)) AS `data` from (`order_fuel` join `fuel` `f3` on((`order_fuel`.`fuel_type` = `f3`.`fid`))) where (`order_fuel`.`order` = `order`.`oid`)) AS `fuel` from (((`order` join `user` `u` on((`order`.`user` = `u`.`uid`))) join `order_status` `s` on((`s`.`sid` = `order`.`status`))) left join `user` `d` on((`d`.`uid` = `order`.`delivery_man`)))) AS `t` WHERE (`t`.`fuel` is not null)  ;

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
  ADD CONSTRAINT `order_order_status_sid_fk` FOREIGN KEY (`status`) REFERENCES `order_status` (`sid`),
  ADD CONSTRAINT `order_user_uid_fk` FOREIGN KEY (`user`) REFERENCES `user` (`uid`),
  ADD CONSTRAINT `order_user_uid_fk2` FOREIGN KEY (`delivery_man`) REFERENCES `user` (`uid`);

--
-- Ограничения внешнего ключа таблицы `order_fuel`
--
ALTER TABLE `order_fuel`
  ADD CONSTRAINT `order_fuel_fuel_fid_fk` FOREIGN KEY (`fuel_type`) REFERENCES `fuel` (`fid`),
  ADD CONSTRAINT `order_fuel_order_oid_fk` FOREIGN KEY (`order`) REFERENCES `order` (`oid`);

--
-- Ограничения внешнего ключа таблицы `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_role_rid_fk` FOREIGN KEY (`role`) REFERENCES `role` (`rid`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
