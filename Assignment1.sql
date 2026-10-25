use BikeStores;

-- 1.1

SELECT 
    product_name, 
    list_price, 
    list_price / 1000.0 AS price_in_thousands
FROM production.products;

--1.2

SELECT DISTINCT state
FROM sales.customers;

--1.3
SELECT TOP 5 
    product_name, 
    list_price
FROM production.products
ORDER BY list_price ASC;

--1.4

SELECT *
FROM production.products
WHERE list_price BETWEEN 200 AND 600
  AND category_id IN (1, 6);

  --1.5
  SELECT product_name, category_id, list_price
FROM production.products
WHERE (category_id = 1 OR category_id = 6) 
  AND list_price < 1000;
-- Or using IN:
-- WHERE category_id IN (1, 6) AND list_price < 1000;

--1,6
SELECT *
FROM sales.customers
WHERE email LIKE '%.com'
  AND last_name LIKE 'M%';

  --1.7
  SELECT product_name, list_price
FROM production.products
ORDER BY list_price DESC
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;

--1.8
SELECT *
FROM sales.order_items
WHERE discount IS NOT NULL;