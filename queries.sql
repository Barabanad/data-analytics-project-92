-- 1 продавцы, у которых наибольшая выручка
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller, -- CONCAT объединяет имя и фамилию сотрудника => получаем имя продавца в виде одной строки
    COUNT(s.sales_id) AS operations, -- Подсчет количества сделок
    FLOOR(SUM(p.price * s.quantity)) AS income -- Вычисляет суммарную выручку для каждого продавца, округляя в меньшую сторону до целого
FROM 
    sales s
JOIN 
    employees e ON s.sales_person_id = e.employee_id
JOIN 
    products p ON s.product_id = p.product_id
GROUP BY 
    seller
ORDER BY 
    income DESC
LIMIT 10;
-- 2 Продавцы, чья выручка ниже средней выручки всех продавцов
WITH total_sales AS (
    SELECT 
        s.sales_person_id,
        SUM(p.price * s.quantity) AS total_income
    FROM 
        sales s
    JOIN 
        products p ON s.product_id = p.product_id
    GROUP BY 
        s.sales_person_id
), -- CTE для вычисления: суммарной выручки для каждого продавца, соединили sales с products по product_id
average_income AS (
    SELECT 
        AVG(total_income) AS avg_income
    FROM 
        total_sales
) -- CTE для вычисления средней выручки всех продавцов 

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(ts.total_income) AS total_income
FROM 
    total_sales ts
JOIN 
    employees e ON ts.sales_person_id = e.employee_id
JOIN 
    average_income ai ON ts.total_income < ai.avg_income -- соединение результатов с CTE avg_income и фильтрация < avg_income 
ORDER BY 
    total_income ASC;
-- 3 Выручка по каждому продавцу и дню недели
   SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TO_CHAR(s.sale_date, 'Day') AS day_of_week,
    FLOOR(SUM(p.price * s.quantity))::integer AS income
FROM 
    sales s
JOIN  
    employees e ON s.sales_person_id = e.employee_id
JOIN 
    products p ON s.product_id = p.product_id
GROUP BY 
    seller, EXTRACT(DOW FROM s.sale_date), TO_CHAR(s.sale_date, 'Day')
ORDER BY 
    EXTRACT(DOW FROM s.sale_date), seller; -- группировка и сортировка по дню недели, продавцу