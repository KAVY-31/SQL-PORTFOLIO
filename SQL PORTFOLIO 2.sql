#-----------------------------------------------------------SQL PORTFOLIO---------------------------------------------------------------------------------------------------------------
CREATE database SQL_Portfolio;
use sql_portfolio;

CREATE TABLE CUSTOMERS(CUSTOMER_ID INT,
                       NAME varchar(30),
                       EMAIL varchar(100),
                       CREATED_DATE DATE,
                       COUNTRY VARCHAR(30));


INSERT INTO CUSTOMERS VALUES(1,"Alice Johnson","Alice@example.com","2023-01-10","USA"),
							(2,"Bob Smith","bob@example.com","2023-02-15","Canada"),
                            (3,"Carol White","carol@example.com","2023-03-20","USA");


CREATE TABLE ORDERSS(ORDER_ID INT,CUSTOMER_ID INT,ORDER_DATE DATE,TOTAL_AMOUNT INT,STATUS VARCHAR(30));


INSERT INTO ORDERSS VALUES(1,1,"2023-03-01",120.00,"Completed"),
                          (2,2,"2023-03-05",85.50,"Completed"),
                          (3,1,"2023-04-15",45.00,"Pending"),
                          (4,3,"2023-05-10",150.00,"Completed"),
                          (5,2,"2023-06-25",75.00,"Cancelled");
                          
SELECT * FROM CUSTOMERS;
SELECT * FROM ORDERSS;

#	Write a query to retrieve order details along with the customer's name and email.

SELECT ORDER_ID,ORDERSS.CUSTOMER_ID,NAME,EMAIL,ORDER_DATE,TOTAL_AMOUNT,STATUS
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID;


#	Show each customer's name and the total number of orders they have placed.

SELECT NAME,count(ORDER_ID) AS TOTAL_ORDERS
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID
GROUP BY NAME;

#	Write a query to calculate the total amount spent by each customer.

SELECT NAME,SUM(TOTAL_AMOUNT) AS TOTAL_AMOUNT
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID
GROUP BY NAME;


#	Show the count of orders for each order status (e.g., 'Completed', 'Pending', 'Cancelled').

SELECT STATUS,COUNT(ORDER_ID) AS TOTAL_ORDERS_STATUS
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID
GROUP BY STATUS;


# 	List the names of customers who have placed orders with a total amount greater than the average order amount.

SELECT NAME,ORDER_ID,TOTAL_AMOUNT
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID
WHERE TOTAL_AMOUNT>(SELECT AVG(TOTAL_AMOUNT) FROM ORDERSS);

# 	Write a query to get the latest order date for each customer.

SELECT NAME,MAX(ORDER_DATE)
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID
GROUP BY NAME;


#	Calculate the total amount of all orders from customers in each country.

SELECT NAME,COUNTRY,SUM(TOTAL_AMOUNT) OVER (PARTITION BY COUNTRY) AS TOTAL_AMOUNT_COUNTRY
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID;


#	Find the average order value for each customer.

SELECT NAME,AVG(TOTAL_AMOUNT) AS AVG_AMOUNT
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID
GROUP BY NAME;

# 	List all customers who have placed at least one 'Completed' order

SELECT NAME,STATUS
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID
WHERE STATUS="COMPLETED"
GROUP BY NAME;

#	Retrieve all customers who have placed exactly two orders

SELECT ORDERSS.CUSTOMER_ID,NAME
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID
GROUP BY NAME,ORDERSS.CUSTOMER_ID
HAVING COUNT(ORDER_ID)=2;

#	Count the number of customers per country

SELECT COUNTRY,COUNT(CUSTOMERS.CUSTOMER_ID) AS NO_OF_CUST_PER_COUNTRY
FROM CUSTOMERS
GROUP BY COUNTRY;


#	Find each customer's highest and lowest order amounts

SELECT NAME,MAX(TOTAL_AMOUNT) AS MAX_AMOUNT,MIN(TOTAL_AMOUNT) AS MIN_AMOUNT
FROM CUSTOMERS JOIN ORDERSS ON CUSTOMERS.CUSTOMER_ID=ORDERSS.CUSTOMER_ID
GROUP BY NAME;

#END