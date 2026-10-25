use BikeStores;

--2.1
SELECT 
    p.product_name, 
    b.brand_name
FROM production.products p
JOIN production.brands b 
    ON p.brand_id = b.brand_id;

--2.2
SELECT s.store_id, s.store_name
FROM sales.stores s
LEFT JOIN sales.staffs st 
    ON s.store_id = st.store_id
WHERE st.staff_id IS NULL;

--2.3
SELECT p.product_name, s.quantity
FROM production.products AS p
LEFT JOIN production.stocks AS s 
    ON p.product_id = s.product_id
WHERE s.store_id = 1 
  AND s.quantity < 5;

  --2.4
  SELECT 
    m.staff_id AS manager_id,
    m.first_name AS manager_first_name,
    m.last_name AS manager_last_name,
    e.staff_id AS employee_id,
    e.first_name AS employee_first_name,
    e.last_name AS employee_last_name,
    1 AS count_placeholder
FROM sales.staffs e
JOIN sales.staffs m 
    ON e.manager_id = m.staff_id;

--2.5
SELECT 
    i.order_id,
    p.product_name,
    i.quantity
FROM sales.orders o
JOIN sales.order_items i 
    ON o.order_id = i.order_id
JOIN production.products p 
    ON i.product_id = p.product_id
WHERE o.order_id = 1;

--2.6
-- Direct & best approach:
SELECT COUNT(*) AS total_orders
FROM sales.orders;

-- Or if counting from joined result:
SELECT COUNT(DISTINCT o.order_id) AS total_orders
FROM sales.orders o
JOIN sales.order_items i ON o.order_id = i.order_id;