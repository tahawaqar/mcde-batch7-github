use BikeStores;

-------Question 1--------
SELECT first_name, last_name,city
FROM
sales.customers
WHERE
(state = 'NY' or state= 'CA') and email LIKE '%.com' and last_name like 'M%'
ORDER BY city asc, last_name asc;

----- Question 2------
SELECT product_name, list_price, discounted_price
FROM (Select product_name, list_price, (list_price - list_price*10/100) 
as discounted_price 
from production.products 
where list_price>500) as dis
order by list_price desc
offset 10 rows fetch next 10 rows only;
----Question 3-----
SELECT order_id, order_date, required_date, order_status
FROM
sales.orders 
WHERE order_status IN (1,2)
AND shipped_date IS NULL
AND
order_date between '2018-01-01' and '2018-06-30';

----Question 4-----
SELECT SC.first_name + ' ' + SC.last_name AS Full_name, order_id, order_date, store_name, product_name, quantity
FROM 
sales.customers AS SC 
INNER JOIN
sales.orders AS SO
ON  SO.customer_id = SC.customer_id
INNER JOIN
sales.stores AS SS
ON SO.store_id = SS.store_id
INNER JOIN
production.stocks AS PS
ON PS.store_id = SS.store_id
INNER JOIN 
production.products AS PP
ON PS.product_id = PP.product_id

-----QUESTION 5-----
SELECT product_name, category_name, brand_name
FROM
production.products AS PP
LEFT JOIN
production.categories AS PC
ON PP.category_id = PC.category_id
LEFT JOIN
production.brands AS PB
ON PP.brand_id =PB.brand_id
LEFT JOIN 
production.stocks AS PS
ON PS.product_id = PP.product_id
LEFT JOIN
sales.stores AS SS
ON PS.store_id = SS.store_id
LEFT JOIN
sales.orders AS SO
ON SO.store_id = SS.store_id
WHERE 
shipped_date IS NULL;

----Question 6----
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS staff_full_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_full_name,
    st.store_name
FROM sales.staffs s
LEFT JOIN sales.staffs m ON s.manager_id = m.staff_id
INNER JOIN sales.stores st ON s.store_id = st.store_id;



-- Q7(a).
CREATE VIEW sales.vw_order_details AS
SELECT 
    o.order_id,
    o.order_date,
    o.order_status,
    c.customer_id,
    c.first_name,
    c.last_name,
    p.product_name,
    oi.quantity,
    (oi.quantity * oi.list_price * (1 - oi.discount)) AS line_total
FROM sales.orders o
INNER JOIN sales.customers c ON o.customer_id = c.customer_id
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
INNER JOIN production.products p ON oi.product_id = p.product_id;

SELECT * FROM sales.vw_order_details

-- Q7(b).
SELECT 
    customer_id,
    first_name,
    last_name,
    SUM(line_total) AS total_spend
FROM sales.vw_order_details
WHERE order_status = 4
GROUP BY customer_id, first_name, last_name
HAVING SUM(line_total) > 10000
ORDER BY total_spend DESC;

-- Q8.
SELECT TOP 5
    c.category_name,
    b.brand_name,
    COUNT(DISTINCT oi.order_id) AS distinct_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM production.categories c
INNER JOIN production.products p ON c.category_id = p.category_id
INNER JOIN production.brands b ON p.brand_id = b.brand_id
INNER JOIN sales.order_items oi ON p.product_id = oi.product_id
GROUP BY c.category_name, b.brand_name
HAVING COUNT(DISTINCT oi.order_id) >= 20
ORDER BY total_revenue DESC;

-- Q9.
SELECT 
    st.store_name,
    YEAR(o.order_date) AS order_year,
    COUNT(DISTINCT o.order_id) AS distinct_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.stores st
INNER JOIN sales.orders o ON st.store_id = o.store_id
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY st.store_name, YEAR(o.order_date)
ORDER BY st.store_name, order_year;

-- Q10.
SELECT first_name, last_name
FROM sales.customers
WHERE customer_id IN (
    SELECT customer_id
    FROM sales.orders
    WHERE order_id IN (
        SELECT order_id
        FROM sales.order_items
        WHERE product_id IN (
            SELECT product_id
            FROM production.products
            WHERE brand_id IN (
                SELECT brand_id
                FROM production.brands
                WHERE brand_name = 'Electra'
            )
        )
    )
);

-- Q11. NOT IN, NULL-safe
SELECT first_name, last_name, customer_id
FROM sales.customers
WHERE customer_id NOT IN (
    SELECT customer_id 
    FROM sales.orders 
    WHERE customer_id IS NOT NULL
);

-- Q12.
SELECT 
    dt.category_name,
    dt.total_revenue
FROM (
    SELECT 
        c.category_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM production.categories c
    INNER JOIN production.products p ON c.category_id = p.category_id
    INNER JOIN sales.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_name
) AS dt
WHERE dt.total_revenue > (
    SELECT AVG(sub.total_revenue)
    FROM (
        SELECT SUM(oi2.quantity * oi2.list_price * (1 - oi2.discount)) AS total_revenue
        FROM production.categories c2
        INNER JOIN production.products p2 ON c2.category_id = p2.category_id
        INNER JOIN sales.order_items oi2 ON p2.product_id = oi2.product_id
        GROUP BY c2.category_id
    ) AS sub
)
ORDER BY dt.total_revenue DESC;

