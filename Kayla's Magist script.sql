#HOW MANY ORDERS ARE IN THE DATA SET?
SELECT COUNT(*) FROM orders;
	# 99,441 total orders
    
    
#HOW MANY PRODUCTS HAVE BEEN SOLD?
SELECT DISTINCT COUNT(order_item_id) FROM order_items
JOIN orders
ON orders.order_id = order_items.order_id;
	# 112,650 products sold


#ARE ORDERS ACTUALLY DELIVERED?
SELECT order_status, COUNT(*) FROM orders
GROUP BY order_status;
	# 96,478 delivered of 99,441 total orders
    # 97.02% of orders are delivered


#IS MAGIST HAVING USER GROWTH?
SELECT YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp), COUNT(customer_id)
FROM orders
GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp);


#HOW MANY PRODUCTS ARE THERE IN PRODUCTS TABLE?
SELECT COUNT(DISTINCT product_id) FROM products;
	#32,951 total products


#WHAT ARE THE CATEGORIES WITH THE MOST PRODUCTS?
SELECT product_category_name, COUNT(*) FROM products
GROUP BY product_category_name
ORDER BY COUNT(*) DESC
LIMIT 10;


#HOW MANY OF THOSE PRODUCTS WERE PRESENT IN ACTUAL TRANSACTIONS?
SELECT COUNT(DISTINCT product_id) FROM order_items;


#WHAT'S THE PRICE FOR THE MOST EXPENSIVE AND CHEAPEST PRODUCT?
SELECT MIN(price), MAX(price) FROM order_items;


#WHAT ARE THE HIGHEST AND LOWEST PAYMENT VALUES?
SELECT MIN(payment_value), MAX(payment_value) FROM order_payments;


#WHAT CATEGORIES OF TECH PRODUCTS DOES MAGIST HAVE?
SELECT DISTINCT product_category_name_english FROM product_category_name_translation;
	# audio, electronics, computers_accessories, pc_gamer, computers, tablets_printing_image, telephony, fixed_telephoney
	# potuguese = "audio", "eletronicos", "informatica_acessorios", "pc_gamer", "pcs", "tablets_impressao_imagem, telefonia", "telefonia_fixa"
SELECT product_category_name FROM product_category_name_translation WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony");



#HOW MANY OF THESE TECH PRODUCTS HAVE BEEN SOLD (WITHIN THE TIME WINDOW OF THE DATABASE SNAPSHOT)? 
SELECT COUNT(*) AS tech_products_sold FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
JOIN products ON products.product_id = order_items.product_id 
WHERE product_category_name IN ("audio", "eletronicos", "informatica_acessorios", "pc_gamer", "pcs", "tablets_impressao_imagem, telefonia", "telefonia_fixa");
	# 11,434 tech products sold within 25 months



#WHAT PERCENT DOES THAT REPRESENT FROM THE OVERALL NUMBER OF PRODUCTS SOLD?	
SELECT COUNT(*) FROM order_items;
	# 11,434 tech products sold out of 112,650
    
SELECT ROUND(11434 / COUNT(*) * 100 , 2) AS percent_of_sales
FROM order_items;
    # 10.15%



#WHAT'S THE AVERAGE PRICE OF A PRODUCT BEING SOLD?
SELECT ROUND(AVG(price), 2) AS average_price FROM order_items;
	# average price = 120.65

SELECT MIN(price), MAX(price), ROUND(AVG(price), 2) FROM order_items
JOIN products ON order_items.product_id = products.product_id
WHERE product_category_name IN ("audio", "eletronicos", "informatica_acessorios", "pc_gamer", "pcs", "tablets_impressao_imagem, telefonia", "telefonia_fixa");
# min price = 3.90, max price = 6,729.00 , avg price = 123.05
# Eniac avg = 540



#ARE EXPENSIVE TECH PRODUCTS POPULAR?
SELECT COUNT(order_item_id), product_category_name,
	CASE
		WHEN price < 500 THEN "inexpensive"
		WHEN price < 1000 THEN "expensive"
		ELSE "mid-range" 
	END AS price_category
FROM order_items
JOIN orders ON orders.order_id = order_items.order_id
JOIN products ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "eletronicos", "informatica_acessorios", "pc_gamer", "pcs", "tablets_impressao_imagem, telefonia", "telefonia_fixa")
GROUP BY price_category, product_category_name;	
	# 112,650 total products sold
    # 11,434 tech products = 9.85% of total products sold
    # 249 expensive tech products = 0.22% of total products sold
    
    
    
#HOW MANY MONTHS OF DATA ARE INCLUDED IN THE MAGIST DATABASE?
SELECT TIMESTAMPDIFF(MONTH,MIN(DATE(order_purchase_timestamp)), MAX(DATE(order_purchase_timestamp))) AS number_of_months 
FROM orders;
	# 25 months



#HOW MANY SELLERS ARE THERE? HOW MANY TECH SELLERS ARE THERE? WHAT PERCENT ARE TECH SELLERS?
SELECT COUNT(*) FROM sellers;
	# 3,095 sellers
SELECT COUNT(DISTINCT sellers.seller_id) FROM sellers
JOIN order_items ON sellers.seller_id = order_items.seller_id
JOIN products ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "eletronicos", "informatica_acessorios", "pc_gamer", "pcs", "tablets_impressao_imagem, telefonia", "telefonia_fixa");
	# 400 tech sellers
    # 12.92% of all sellers are tech sellers



#WHAT IS THE TOTAL AMOUNT EARNED BY ALL SELLERS? WHAT IS THE TOTAL AMOUNT EARNED BY ALL TECH SELLERS? 
SELECT ROUND(SUM(order_items.price),2) AS total_amount_earned
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.order_status != "canceled";
	# 13,496,408.43


SELECT ROUND(SUM(price),2) AS total_amount_earned
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
JOIN products ON order_items.product_id = products.product_id
WHERE orders.order_status != "canceled" AND products.product_category_name IN ("audio", "eletronicos", "informatica_acessorios", "pc_gamer", "pcs", "tablets_impressao_imagem, telefonia", "telefonia_fixa");
	# 1,395,363.45
    # 10.34 %
    
    
    
#CAN YOU WORK OUT THE AVERAGE MONTHLY INCOME OF ALL SELLERS? OF TECH SELLERS?
	# avg monthly income of all sellers = 539,856.34
    # avg monthly income of tech sellers = 55,814.54
    
    
    
#WHAT'S THE AVERAGE TIME BETWEEN THE ORDER BEING PLACED AND THE PRODUCT BEING DELIVERED?
SELECT AVG(DATEDIFF(order_delivered_customer_date , order_purchase_timestamp)) AS Average_Delivery_Time
FROM orders
WHERE order_status != "canceled";
	# Average time until delivery = 12.5 days



#HOW MANY ORDERS ARE DELIVERED ON TIME VS ORDERS DELIVERED WITH A DELAY?
SELECT COUNT(*) AS Delivered
FROM orders
WHERE order_status = "delivered";
	# 96,478 total delivered orders
        
SELECT COUNT(*) AS On_Time_Delivery
FROM orders
WHERE DATEDIFF(order_delivered_customer_date , order_estimated_delivery_date) <= 0 
AND order_status = "delivered";
	# 89,805 (92.58%) delivered on time
       
SELECT COUNT(*) AS Delyed_Delivery
FROM orders
WHERE DATEDIFF(order_delivered_customer_date , order_estimated_delivery_date) > 0 
AND order_status = "delivered";
	# 6,665 (7.42%) delivered late


#IS THERE ANY PATTERN FOR DELAYED ORDERS; e.g. BIG PRODUCTS BEING DELAYED MORE OFTEN?
SELECT 
	CASE
		WHEN p.product_weight_g >= 10000 THEN "10kg+"
        WHEN p.product_weight_g >= 5000 THEN '5kg+'
        WHEN p.product_weight_g >= 1000 THEN '1kg+'
        WHEN p.product_weight_g >= 500 THEN '500g+'
        WHEN p.product_weight_g >= 100 THEN '100g+'
        ELSE "< 100g"
	END AS weight,
		AVG(DATEDIFF(o.order_delivered_customer_date , o.order_estimated_delivery_date)) AS avg_delivery_delay
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id 
WHERE DATEDIFF(o.order_delivered_customer_date , o.order_estimated_delivery_date) > 0 AND o.order_status = "delivered"
GROUP BY weight;
	# No pattern based on weight 
    
SELECT COUNT(*) AS Delyed_Delivery
FROM orders o
join customers c on c.customer_id = o.customer_id
join sellers s on 
WHERE DATEDIFF(order_delivered_customer_date , order_estimated_delivery_date) > 0 
AND order_status = "delivered" and 
	