USE OLIST_STORE_ANALYSIS;
SELECT * FROM olist_customers_dataset;
SELECT * FROM olist_order_items;
SELECT * FROM olist_order_payments;
SELECT * FROM olist_order_reviews;
SELECT * FROM orders;
SELECT * FROM olist_products;
SELECT * FROM olist_geolocation_dataset;

#---------------delivered time------------------------------------------------------------------------------------------

select * from orders
where order_delivered_customer_date is null or order_delivered_customer_date='';

select order_delivered_customer_date
from orders
where str_to_date(nullif(order_delivered_customer_date, ''), '%d-%m-%Y %H:%i') is null;

select distinct order_delivered_customer_date from orders
where str_to_date(nullif(order_delivered_customer_date, ''), '%d-%m-%Y %H:%i') is null;

update orders 
set order_delivered_customer_date=null
where str_to_date(nullif(order_delivered_customer_date, ''), '%d-%m-%Y %H:%i') is null;

select * from orders
where str_to_date(nullif(order_delivered_customer_date, ''), '%d-%m-%Y %H:%i') is null;


ALTER TABLE ORDERS ADD order_delivered_customer_datetime datetime;

update orders
set order_delivered_customer_datetime=str_to_date(nullif(order_delivered_customer_date, ''), '%d-%m-%Y %H:%i');

select date( order_delivered_customer_datetime) as delivered_date from orders;

alter table orders drop column order_delivered_customer_date;
alter table orders change order_delivered_customer_datetime order_delivered_customer_date datetime;
select date(order_delivered_customer_date) as delivered_date
from orders;


#--------------------purchasetime---------------------------------------------------------------------
select order_purchase_timestamp from orders;
select date(order_purchase_timestamp) as order_date
from orders;
select str_to_date(order_purchase_timestamp,'%d-%m-%Y %H:%i') as converted_datetime
from orders;
ALTER TABLE ORDERS ADD order_purchase_datetime datetime;
SET SQL_SAFE_UPDATES = 0;
update orders
set order_purchase_datetime=str_to_date(order_purchase_timestamp,'%d-%m-%Y %H:%i');

alter table orders drop column order_purchase_timestamp;
alter table orders change order_purchase_datetime order_purchase_timestamp datetime;

select date(order_purchase_timestamp) as order_date
from orders;

#------------shippingdays---------------------------------------------------------------------------
alter table orders add Shipping_days int;
set sql_safe_updates=0;
update orders set Shipping_days= datediff(order_delivered_customer_date,order_purchase_timestamp);
         
	#--------day_type---------------------------------------------------------------------------------

alter table orders add column Day_type text;
set sql_safe_updates=0;
update orders set Day_type= 
    CASE 
        WHEN DAYOFWEEK(order_purchase_timestamp) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END ;

#---------------------------------------------------------------------------------------------------

#-----KPI 1 WEEKDAY VS WEEKEND PAYMENT STATISTICS----------------------------------------------------------

SELECT O.Day_type,
    COUNT(O.order_id) AS total_orders,
    ROUND(SUM(P.payment_value),2)  AS total_payment,
    ROUND(AVG(P.payment_value),2) AS average_payment,
    CONCAT(ROUND(SUM(P.payment_value)*100/sum(sum(P.payment_value)) over (),2),"%") as Payment_Percentage
FROM orders AS O
JOIN olist_order_payments AS P ON O.order_id=P.order_id
GROUP BY O.Day_type;

#-------------KPI2 NO OF ORDERS WITH REVIEW SCORE 5 AND PAYMENT TYPE AS CREDIT CARD--------------------------

SELECT COUNT(R.order_id) as NO_OF_ORDERS,R.review_score,P.payment_type
from olist_order_reviews AS R JOIN olist_order_payments AS P ON R.order_id=P.order_id
WHERE R.review_score=5 AND P.payment_type="credit_card";

#------------------------KPI3 AVG NO OF DAYS TAKEN FOR ORDER_DELIVERED_CUSTOMER_DATE FOR PET_SHOP---------------

SELECT P.product_category_name,ROUND(AVG(O.Shipping_days),0) AS AVG_NO_OF_DAYS_TAKEN
from orders as O JOIN olist_order_items as I  on O.order_id=I.order_id JOIN olist_products AS P ON P.product_id=I.product_id
WHERE P.product_category_name="pet_shop"
group by P.product_category_name;

#--------------------------KPI 4 AVG PRICE AND PAYMENT VALUES FROM CUSTOMERS OF SAO PAULO CITY--------------------

WITH Avg_Price AS (
    SELECT ROUND(AVG(I.price), 2) AS Avg_Price
    FROM olist_order_items AS I
    JOIN orders AS O ON I.order_id = O.order_id
    JOIN olist_customers_dataset AS C ON O.customer_id = C.customer_id
    WHERE C.customer_city = 'sao paulo'
)
SELECT 
    (SELECT Avg_Price FROM Avg_Price) AS Avg_Price,
    ROUND(AVG(P.payment_value), 2) AS Avg_Payment_Value
FROM olist_order_payments AS P
JOIN orders AS O ON P.order_id = O.order_id
JOIN olist_customers_dataset AS C ON O.customer_id = C.customer_id
WHERE C.customer_city = 'sao paulo';



#-----------------------KPI 5 RELATIONSHIP B/W SHIPPINGDAYS VS REVIEW SCORE-----------------------------------
SELECT R.review_score,ROUND(AVG(O.Shipping_days),0) AS Avg_Shipping_days
from olist_order_reviews as R JOIN orders as O ON R.order_id=O.order_id
group by R.review_score
order by R.review_score DESC;

#-----------------------------------------------END-----------------------------------------------------------------




