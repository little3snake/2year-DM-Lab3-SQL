-- Уровень 1: Создание схемы базы данных
--CREATE DATABASE dm_lab3;
--\c dm_lab3
--\i C:/Users/lab3.sql

-- Таблица: Предприятие
CREATE TABLE enterprise (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    region VARCHAR(100) NOT NULL,
    sale DECIMAL(5, 2) CHECK (sale >= 0)
);

-- Таблица: Подстанция
CREATE TABLE substation (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    region VARCHAR(100) NOT NULL,
    loss DECIMAL(5, 2) CHECK (loss >= 0)
);

-- Таблица: Электроэнергия
CREATE TABLE electricity (
    id SERIAL PRIMARY KEY,
    time_period VARCHAR(50) NOT NULL,
    cost_per_1kw DECIMAL(10, 2) CHECK (cost_per_1kw >= 0),
    donor VARCHAR(100) NOT NULL,
    total_limit DECIMAL(10, 2) CHECK (total_limit >= 0)
);

-- Таблица: Потребление
CREATE TABLE consumption (
    account_number SERIAL PRIMARY KEY,
    weekday VARCHAR(25) NOT NULL,
    enterprise_id INT REFERENCES enterprise(id),
    substation_id INT REFERENCES substation(id),
    electricity_id INT REFERENCES electricity(id),
    expenditure DECIMAL(10, 2) CHECK (expenditure >= 0),
    to_be_paid DECIMAL(10, 2) CHECK (to_be_paid >= 0)
);

-- Вставка данных
-- Таблица: Предприятие
INSERT INTO enterprise (id, name, region, sale) VALUES
(1, 'Авиационный завод', 'Нижегородская', 5),
(2, 'Приборостроительный завод', 'Владимирская', 0),
(3, 'ГАЗ', 'Нижегородская', 5),
(4, 'Невский завод', 'Ленинградская', 2),
(5, 'ЗИЛ', 'Московская', 2);

-- Таблица: Подстанция
INSERT INTO substation (id, name, region, loss) VALUES
(1, 'Главная-Южная', 'Нижегородская', 2),
(2, 'N12', 'Московская', 2),
(3, 'Западная', 'Ленинградская', 2),
(4, 'Центральная', 'Московская', 1),
(5, 'N23', 'Владимирская', 2),
(6, 'Горьковская', 'Нижегородская', 2);

-- Таблица: Электроэнергия
INSERT INTO electricity (id, time_period, cost_per_1kw, donor, total_limit) VALUES
(1, '0-3', 7000, 'Ленинградская', 600000),
(2, '4-6', 8000, 'Нижегродская', 580000),
(3, '7-8', 9000, 'Московская', 580000),
(4, '9-11', 10000, 'Свердловская', 550000),
(5, '12-14', 14000, 'Свердловская', 500000),
(6, '15-18', 10000, 'Владимирская', 700000),
(7, '21-24', 7000, 'Нижегородская', 720000);

-- Таблица: Потребление
INSERT INTO consumption (account_number, weekday, enterprise_id, substation_id, electricity_id, expenditure, to_be_paid) VALUES
(37111, 'Понедельник', 2, 2, '001', 200, 1400000),
(37112, 'Понедельник', 3, 5, '001', 200, 1400000),
(37113, 'Вторник', 1, 2, '005', 10, 140000),
(37114, 'Вторник', 2, 5, '004', 250, 2500000),
(37115, 'Вторник', 2, 5, '003', 200, 1800000),
(37116, 'Вторник', 3, 5, '002', 150, 1200000),
(37117, 'Вторник', 4, 3, '001', 200, 1400000),
(37118, 'Вторник', 4, 4, '002', 100, 80000),
(37119, 'Среда', 2, 3, '005', 300, 4200000),
(37120, 'Среда', 2, 5, '007', 120, 84000),
(37121, 'Среда', 3, 5, '001', 200, 140000),
(37122, 'Среда', 5, 2, '006', 100, 1000000),
(37123, 'Четверг', 5, 5, '004', 110, 1100000),
(37124, 'Четверг', 5, 4, '003', 90, 810000),
(37125, 'Пятница', 5, 4, '005', 300, 4200000),
(37126, 'Пятница', 5, 1, '004', 100, 1000000);

-- Вывод данных каждой таблицы
SELECT * FROM enterprise;
SELECT * FROM substation;
SELECT * FROM electricity;
SELECT * FROM consumption;

-- Запросы:
-- Различные дни, когда зафиксировано потребление электроэнергии, отсортированные по порядку
SELECT DISTINCT weekday
FROM consumption
ORDER BY weekday;


-- Все названия предприятий
SELECT name
FROM enterprise;

-- Области, где расположены подстанции
SELECT DISTINCT region
FROM substation
ORDER BY region;

-- Подстанции в Нижегородской или Московской области
SELECT id, name AS substation
FROM substation
WHERE region IN ('Нижегородская', 'Московская');

-- Временные интервалы, где Свердловская область донор, а стоимость > 10000
SELECT time_period 
FROM electricity
WHERE donor = 'Свердловская' AND cost_per_1kw > 10000;

-- Предприятия с "завод" в названии и скидкой более 1%
SELECT id, name AS enterprise 
FROM enterprise 
WHERE name ILIKE '%завод%' AND sale > 1 
ORDER BY name, region;

-- Учетный номер, название предприятия и сумма к оплате
SELECT c.account_number, e.name, c.to_be_paid
FROM consumption c
JOIN enterprise e ON c.enterprise_id = e.id
ORDER BY c.to_be_paid;

-- Дата, название подстанции и расход электроэнергии
SELECT c.weekday, s.name, c.expenditure
FROM consumption c
JOIN substation s ON c.substation_id = s.id;

-- Учетный номер, название предприятия, дата, где подстанции Московской обл.
SELECT c.account_number, e.name, c.weekday
FROM consumption c
JOIN enterprise e ON c.enterprise_id = e.id
JOIN substation s ON c.substation_id = s.id
WHERE s.region = 'Московская';

-- Места расположения подстанций со скидкой >= 5%, не позднее четверга
SELECT DISTINCT s.region
FROM consumption c
JOIN enterprise e ON c.enterprise_id = e.id
JOIN substation s ON c.substation_id = s.id
WHERE e.sale >= 5 AND c.weekday IN ('Понедельник', 'Вторник', 'Среда', 'Четверг')
ORDER BY s.region;

-- Доноры для предприятий Московской или Владимирской обл. с потерями > 1.5%
SELECT DISTINCT el.donor
FROM consumption c
JOIN electricity el ON el.id = c.enterprise_id
JOIN substation s ON s.id = c.substation_id
JOIN enterprise e ON e.id = c.enterprise_id
WHERE s.loss > 1.5 AND e.region IN ('Московская', 'Владимирская');

-- Интервалы, стоимость, донор, для потребителя "ГАЗ", расход > 100
SELECT el.time_period, el.cost_per_1kw, el.donor
FROM consumption c
JOIN electricity el ON el.id = c.enterprise_id
JOIN enterprise e ON e.id = c.enterprise_id
WHERE e.name = 'ГАЗ' AND c.expenditure > 100;

-- Модификация значений столбца с оплатой (с учетом скидки)
UPDATE consumption 
SET to_be_paid = to_be_paid * (1 - e.sale / 100)
FROM enterprise e
WHERE consumption.enterprise_id = e.id;
-- Для демонстрации
SELECT * FROM consumption;

-- Расширение таблицы потребления столбцом "величина потерь"
ALTER TABLE consumption ADD COLUMN loss_amount DECIMAL(5, 2);
UPDATE consumption 
SET loss_amount = s.loss
FROM substation s
WHERE consumption.substation_id = s.id;
-- Для демонстрации
SELECT * FROM consumption;

-- Уровень 2

-- Используя операцию IN (NOT IN)

-- 1. Найти подстанции, не предоставлявшие энергии предприятиям из Н.Новгорода
SELECT id, name
FROM substation
WHERE id NOT IN (
    SELECT c.substation_id
    FROM consumption c
    JOIN enterprise e ON c.enterprise_id = e.id
    WHERE e.region = 'Нижегородская'
);

-- 2. Найти предприятия, которые потребляли эл.-энергию через подстанции с потерями меньше 2%
SELECT DISTINCT e.id, e.name
FROM enterprise e
JOIN consumption c ON e.id = c.enterprise_id
WHERE c.substation_id IN (
    SELECT id
    FROM substation
    WHERE loss < 2
);

-- 7.a. Учетный номер, название предприятия и сумма к оплате
SELECT c.account_number, 
       (SELECT name FROM enterprise WHERE id = c.enterprise_id) AS name, 
       c.to_be_paid
FROM consumption c
WHERE c.enterprise_id IN (
    SELECT id
    FROM enterprise
);

-- 7.c. Учетный номер, название предприятия, дата, где подстанции Московской обл.
SELECT c.account_number, 
       (SELECT name FROM enterprise WHERE id = c.enterprise_id) AS name, 
       c.weekday
FROM consumption c
WHERE c.enterprise_id IN (
    SELECT id
    FROM enterprise
)
AND c.substation_id IN (
    SELECT id 
    FROM substation 
    WHERE region = 'Московская'
);

-- Используя операции ALL-ANY

-- 1. Временной интервал подачи энергии, в который стоимость 1KW максимальна
SELECT time_period
FROM electricity
WHERE cost_per_1kw = (SELECT MAX(cost_per_1kw) FROM electricity);

-- 2. Найти среди предприятий со скидкой меньше максимальной предприятие,
-- для которого зафиксировано минимальное потребление электроэнергии
SELECT e.id, e.name
FROM enterprise e
JOIN consumption c ON e.id = c.enterprise_id
WHERE e.sale < (SELECT MAX(sale) FROM enterprise)
GROUP BY e.id, e.name
HAVING SUM(c.expenditure) <= ALL (
    SELECT SUM(c2.expenditure)
    FROM consumption c2
    JOIN enterprise e2 ON c2.enterprise_id = e2.id
    WHERE e2.sale < (SELECT MAX(sale) FROM enterprise)
    GROUP BY e2.id
);

-- 3. Найти подстанции, которые предоставляли электроэнергию на самую большую стоимость во вторник
SELECT s.id, s.name
FROM substation s
WHERE s.id IN (
    SELECT c.substation_id
    FROM consumption c
    JOIN electricity el ON c.electricity_id = el.id
    WHERE c.weekday = 'Вторник' AND el.cost_per_1kw >= ALL (
        SELECT cost_per_1kw
        FROM electricity
    )
);
-- 3. Найти подстанции, которые предоставляли электроэнергию на самую большую сумму во вторник
SELECT s.id, s.name
FROM substation s
JOIN consumption c ON s.id = c.substation_id
WHERE c.weekday = 'Вторник'
GROUP BY s.id, s.name
HAVING SUM(c.to_be_paid) = ANY (
    SELECT SUM(c2.to_be_paid)
    FROM consumption c2
    WHERE c2.weekday = 'Вторник'
    GROUP BY c2.substation_id
);

-- 4. Запрос задания 7.b
-- Определить места расположения и названия подстанций, предоставивших электроэнергию предприятиям со скидкой >= 5%, не позднее четверга
SELECT DISTINCT s.name, s.region 
FROM substation s
JOIN consumption c ON s.id = c.substation_id
WHERE c.enterprise_id = ANY (
    SELECT id
    FROM enterprise
    WHERE sale >= 5
)
AND c.weekday IN ('Понедельник', 'Вторник', 'Среда', 'Четверг')
ORDER BY s.name, s.region;

-- Используя операцию UNION

-- Области, где расположены предприятия и подстанции
SELECT DISTINCT region
FROM enterprise
UNION
SELECT DISTINCT region
FROM substation;

-- Используя операцию EXISTS (NOT EXISTS)

-- 1. Найти предприятия, использовавшие для потребления все подстанции своей области
SELECT e.id, e.name
FROM enterprise e
WHERE NOT EXISTS (
    SELECT 1
    FROM substation s
    WHERE s.region = e.region
      AND NOT EXISTS (
          SELECT 1
          FROM consumption c
          WHERE c.enterprise_id = e.id
            AND c.substation_id = s.id
      )
);


-- 2. Найти интервалы потребления электроэнергии, в которые все предприятия ее использовали
SELECT el.time_period
FROM electricity el
WHERE NOT EXISTS (
    SELECT 1
    FROM enterprise e
    WHERE NOT EXISTS (
        SELECT 1
        FROM consumption c
        WHERE c.electricity_id = el.id AND c.enterprise_id = e.id
    )
)
ORDER BY el.id;


-- 3. Найти интервалы потребления электроэнергии, в которые не использовались подстанции с потерями более 1%
SELECT el.time_period
FROM electricity el
WHERE NOT EXISTS (
    SELECT 1
    FROM substation s
    WHERE s.loss > 1 AND EXISTS (
        SELECT 1
        FROM consumption c
        WHERE c.electricity_id = el.id AND c.substation_id = s.id
    )
)
ORDER BY el.id;

-- 4. Найти предприятия, не использующие для потребления подстанции своей области с потерями более 1%
SELECT e.id, e.name, e.region
FROM enterprise e
WHERE NOT EXISTS (
    SELECT 1
    FROM substation s
    WHERE s.region = e.region AND s.loss > 1 AND
          EXISTS (
              SELECT 1
              FROM consumption c
              WHERE c.enterprise_id = e.id AND c.substation_id = s.id
          )
)
ORDER BY e.id;

-- Используя агрегатные функции

-- 1. Определить число различных предприятий, которые получали электроэнергию через подстанции Нижегородской области в промежутке между 7 и 14 часами
-- должен быть =1 (последняя строчка)
SELECT COUNT(DISTINCT c.enterprise_id) AS enterprise_count
FROM consumption c
JOIN substation s ON c.substation_id = s.id
JOIN electricity el ON c.electricity_id = el.id
WHERE s.region = 'Нижегородская' AND el.time_period IN ('7-8', '9-11', '12-14');

-- 2. Определить какую сумму за электроэнергию должен заплатить ГАЗ
SELECT SUM(c.to_be_paid) AS total_payment
FROM consumption c
JOIN enterprise e ON c.enterprise_id = e.id
WHERE e.name = 'ГАЗ';

-- 3. Какие подстанции имеют потери больше средних
SELECT *
FROM substation
WHERE loss > (SELECT AVG(loss) FROM substation);

-- 4. Найти количество подстанций, через которые получают электроэнергию предприятия Московской области
SELECT COUNT(DISTINCT c.substation_id)
FROM consumption c
JOIN enterprise e ON c.enterprise_id = e.id
WHERE e.region = 'Московская';

-- Используя средства группировки

-- 1. Для каждого временного интервала определить число различных предприятий, потребляющих электроэнергию
SELECT el.time_period, COUNT(DISTINCT c.enterprise_id) AS enterprise_count
FROM consumption c
JOIN electricity el ON c.electricity_id = el.id
GROUP BY el.time_period;

-- 2. Какие предприятия в сумме заплатили за энергию больше чем 10000000
SELECT e.name, SUM(c.to_be_paid) AS total_paid
FROM consumption c
JOIN enterprise e ON c.enterprise_id = e.id
GROUP BY e.name
HAVING SUM(c.to_be_paid) > 10000000;

-- 3. Для каждого временного интервала и предприятия со скидкой более 2% определить суммарную величину потребленной энергии
SELECT el.time_period, e.name, SUM(c.expenditure) AS total_expenditure
FROM consumption c
JOIN electricity el ON c.electricity_id = el.id
JOIN enterprise e ON c.enterprise_id = e.id
WHERE e.sale > 2
GROUP BY el.time_period, e.name
ORDER BY 
    CASE 
        WHEN el.time_period = '0-3' THEN 1
        WHEN el.time_period = '4-6' THEN 2
        WHEN el.time_period = '7-8' THEN 3
        WHEN el.time_period = '9-11' THEN 4
        WHEN el.time_period = '12-14' THEN 5
        WHEN el.time_period = '15-18' THEN 6
        WHEN el.time_period = '21-24' THEN 7
        ELSE 8  -- для всех других значений (если вдруг появляются другие интервалы)
    END,
    e.name;

-- 4. Для всех подстанций определить выдачу электроэнергии в каждом временном интервале
SELECT s.name, el.time_period, SUM(c.expenditure) AS total_expenditure
FROM consumption c
JOIN electricity el ON c.electricity_id = el.id
JOIN substation s ON c.substation_id = s.id
GROUP BY s.name, el.time_period
ORDER BY s.name, el.time_period;
