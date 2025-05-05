-- main concern--
-- 1. is Magist a good fit for high-end tech products? --
-- 2.  Are orders delivered on time? ------



USE magist;

SELECT COUNT(order_id) FROM orders;
SELECT COUNT(DISTINCT order_id) FROM order_items;


/*****
In relation to the products:
*****/

-- 1. What categories of tech products does Magist have?
-- How many products of these tech categories have been sold
-- (within the time window of the database snapshot)?
SELECT * FROM products
WHERE product_category_name IN
('electronics', 'audio', 'computers_accessories',
'pc_gamer','computers','telephony','tablets_printing_image');

SELECT COUNT(product_id) FROM products as p
JOIN product_category_name_translation as pcnt
ON p.product_category_name =  pcnt.product_category_name
WHERE pcnt.product_category_name_english IN
('electronics', 'audio', 'computers_accessories',
'pc_gamer','computers','telephony','tablets_printing_image');




SELECT COUNT(distinct product_id)
FROM order_items as oi
JOIN products as p
-- ON oi.product_id = p.product_id
USING (product_id)
JOIN product_category_name_translation as pcnt
ON p.product_category_name =  pcnt.product_category_name
WHERE pcnt.product_category_name_english IN
('electronics', 'audio', 'computers_accessories',
'pc_gamer','computers','telephony','tablets_printing_image');
-- 3390

-- What percentage does 
-- that represent from the overall number of products sold?
SELECT COUNT(distinct product_id)
FROM order_items as oi
JOIN products as p
-- ON oi.product_id = p.product_id
USING (product_id)
JOIN product_category_name_translation as pcnt
ON p.product_category_name =  pcnt.product_category_name;

SELECT COUNT(distinct product_id)
FROM products as oi;

SELECT 3390/32951;

-- What’s the average price of the products being sold?
SELECT ROUND(avg(price),2)
FROM order_items;

-- Are expensive tech products popular? *
-- * TIP: Look at the function CASE WHEN to accomplish this task.

-- -------------count ----
-- EXPENSIVE	150
-- MEDIUM		500
-- CHEAP		700
-- ---------------
-- first add a column that has either expensive, medium, or cheap
SELECT COUNT(product_id),
CASE
	WHEN price > 1000 THEN "Expensive"
    WHEN price > 100 THEN "Mid-range"
    ELSE "Cheap"
END AS "price_range"
FROM order_items as oi
JOIN products as p
USING (product_id)
JOIN product_category_name_translation as pcnt
ON p.product_category_name =  pcnt.product_category_name
WHERE pcnt.product_category_name_english IN
('electronics', 'audio', 'computers_accessories',
'pc_gamer','computers','telephony','tablets_printing_image') 
GROUP BY price_range;

/*****
In relation to the sellers:
*****/

-- How many months of data are included in the magist database?
SELECT TIMESTAMPDIFF(MONTH,MIN(order_purchase_timestamp),
MAX(order_purchase_timestamp))
FROM orders;

-- How many sellers are there?
SELECT COUNT(seller_id)
FROM sellers;


-- How many Tech sellers are there? 
SELECT COUNT(distinct seller_id)
FROM sellers as s
JOIN order_items as oi USING (seller_id)
JOIN products as p USING (product_id)
JOIN product_category_name_translation as pcnt USING (product_category_name)
WHERE pcnt.product_category_name_english IN
('electronics', 'audio', 'computers_accessories',
'pc_gamer','computers','telephony','tablets_printing_image'); 

-- What is the total amount earned by all sellers?

SELECT  SUM(price)
FROM order_items
JOIN orders USING(order_id)
WHERE order_status NOT IN ('unavailable','canceled');

-- What is the total amount earned by all Tech sellers?
SELECT  SUM(price)
FROM order_items as oi
JOIN orders as o ON oi.order_id = o.order_id
JOIN products as p on p.product_id = oi.product_id
JOIN product_category_name_translation as pcnt ON pcnt.product_category_name = p.product_category_name
WHERE order_status NOT IN ('unavailable','canceled')
AND pcnt.product_category_name_english IN
('electronics', 'audio', 'computers_accessories',
'pc_gamer','computers','telephony','tablets_printing_image');

/*****
In relation to the delivery time:
*****/

-- What’s the average time between the order being placed 
-- and the product being delivered?
-- 14 days
SELECT 
avg(
   DATEDIFF(order_delivered_customer_date,
			order_purchase_timestamp)
	) as "avg_delivery_in_days"
FROM orders
WHERE order_status = 'delivered';

-- How many orders are delivered on time 
-- vs orders delivered with a delay?

-- ON TIME 	1234
-- DELAYED 	234


SELECT 
CASE
	WHEN DATEDIFF(order_estimated_delivery_date,
				  order_delivered_customer_date) <= 0 THEN "on time"
    ELSE "delayed"
END as delivery_status,
COUNT(order_id)
FROM orders
GROUP BY delivery_status;

SELECT 
CASE
	WHEN order_estimated_delivery_date
		<= order_delivered_customer_date THEN "on time"
    ELSE "delayed"
END as delivery_status,
COUNT(order_id)
FROM orders
GROUP BY delivery_status;