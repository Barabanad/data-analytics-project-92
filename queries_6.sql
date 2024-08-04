--1 Подсчет количества покупателей в разных возрастных группах
SELECT 
    CASE  -- Создаем условия:
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        WHEN age > 40 THEN '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM 
    customers
GROUP BY 
    age_category
ORDER BY 
    age_category; -- сгруппировали и отсортировалии по заданному условию
-- 2 Подсчет количества уникальных покупателей
select 
	to_char(s.sale_date, 'YYYY-MM') as date, -- преобразует дату в нужный формат
	COUNT(distinct S.customer_id) as total_customers, --подсчет кол-ва уникальных покупателей с псевдонимом
	floor(sum(p.price * s.quantity)) as income -- суммарная выручка + округление
from 
	sales s
join 
	products p on s.product_id = p.product_id 
group by 
	to_char(s.sale_date, 'YYYY-MM')
order by 
	date; 
-- 3  первая покупка по акции
WITH first_promo_purchase AS (
    SELECT 
        s.customer_id,
        MIN(s.sale_date) AS first_sale_date
    FROM 
        sales s
    JOIN 
        products p ON s.product_id = p.product_id
    WHERE 
        p.price = 0
    GROUP BY 
        s.customer_id
) -- дата первой покупки для каждого покупателя, если p = 0 

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer, --объединение
    fpp.first_sale_date AS sale_date, -- дата первой покупки с псевдонимом
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM 
    first_promo_purchase fpp - объявили псевдоним
JOIN 
    sales s ON fpp.customer_id = s.customer_id 
          AND fpp.first_sale_date = s.sale_date
          AND EXISTS (
              SELECT 1
              FROM products p
              WHERE s.product_id = p.product_id
              AND p.price = 0
          )
JOIN 
    customers c ON fpp.customer_id = c.customer_id
JOIN 
    employees e ON s.sales_person_id = e.employee_id
ORDER BY 
    c.customer_id;