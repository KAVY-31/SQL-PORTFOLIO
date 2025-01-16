use classicmodels;
select * from employees;
describe employees;


#---------------------------------------Q1-SELECT CLAUSE-----------------------------------------------------------------------------------
#Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)

#a.	Fetch the employee number, first name and last name of those employees who are working as 
#Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)
#b.	Show the unique productline values containing the word cars at the end from the products table.


select employeeNumber,firstName,lastName 
from employees where jobTitle="Sales Rep" and reportsTo=1102;
select distinct(productLine) from products where productLine like "%cars";


#  ------------------------------------------ Q2-CASE STATEMENTS------------------------------------------------------------------------------------
#a. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
                       # "North America" for customers from USA or Canada
                        #"Europe" for customers from UK, France, or Germany
                        #"Other" for all remaining countries
     #Select the customerNumber, customerName, and the assigned region as "CustomerSegment".


select * from customers;
select distinct country from customers;

select customerNumber,customerName, 
case when country = "USA" or country = "Canada" then "North America"
     when country = "UK" or country = "France" or country = "Germany" then "Europe"
     else "Other"
     end as CustomerSegment
     from customers;
     
     
#  ------------------------------------------------ Q3-GROUP BY------------------------------------------------------------------------------------

#a a.	Using the OrderDetails table, identify the top 10 products (by productCode) 
#with the highest total order quantity across all orders.



SELECT * FROM ORDERDETAILS;
select productcode,sum(quantityordered) as totalordered
from orderdetails
group by productcode
order by totalordered desc
limit 10;

#b b.	Company wants to analyse payment frequency by month. Extract the month name from the payment date 
#to count the total number of payments for each month and include only those months with a payment count exceeding 20. 
#Sort the results by total number of payments in descending order.  (Refer Payments table). 



select * from payments;

select monthname(paymentDate) as payment_month , count(paymentDate) as num_payments 
from payments
group by payment_month
having num_payments > 20 
order by num_payments desc;


#  --------------------------------------------------------Q4 -CONSTRAINS------------------------------------------------------------------------------------


#a Create a new database named and Customers_Orders and add the following tables as per the description

#Create a table named Customers to store customer information. Include the following columns:

#customer_id: This should be an integer set as the PRIMARY KEY and AUTO_INCREMENT.
#first_name: This should be a VARCHAR(50) to store the customer's first name.
#last_name: This should be a VARCHAR(50) to store the customer's last name.
#email: This should be a VARCHAR(255) set as UNIQUE to ensure no duplicate email addresses exist.
#phone_number: This can be a VARCHAR(20) to allow for different phone number formats.


create database Customer_Orders;
use Customer_Orders;
create table Customers(customer_id int unique primary key  auto_increment,
                       first_name varchar(50) not null,
                       last_name varchar(50) not null,
                       email varchar(255) unique,
                       phone_number varchar(20));
select * from customers;
describe customers;
                       
#b b.	Create a table named Orders to store information about customer orders. Include the following columns:

#order_id: This should be an integer set as the PRIMARY KEY and AUTO_INCREMENT.
#customer_id: This should be an integer referencing the customer_id in the Customers table  (FOREIGN KEY).
#order_date: This should be a DATE data type to store the order date.
#total_amount: This should be a DECIMAL(10,2) to store the total order amount.
     	
#Constraints:
#a)	Set a FOREIGN KEY constraint on customer_id to reference the Customers table.
#b)	Add a CHECK constraint to ensure the total_amount is always a positive value.


create table Orders(order_id int primary key auto_increment,
                    customer_id int, foreign key( Customer_id) references customers(customer_id),
                    order_date date,
                    total_amount decimal(10,2) check(total_amount > 0));
select * from Orders;
describe Orders;



# -------------------------------------------------- Q5-JOINS-----------------------------------------------------------------------------------
    # List the top 5 countries (by order count) that Classic Models ships to.
    #(Use the Customers and Orders tables)
    
    
select *from customers;
select *from orders;
select C.country,count(O.ordernumber) as order_count
from customers as C
join orders AS O on C.customernumber=O.customernumber
group by C.country
order by order_count desc
limit 5;



# ----------------------------------------------- Q6-SELF JOIN-------------------------------------------------------------------------------------
# Create a table project with below fields.
#	EmployeeID : integer set as the PRIMARY KEY and AUTO_INCREMENT.
#	FullName: varchar(50) with no null values
#	Gender : Values should be only ‘Male’  or ‘Female’
#	ManagerID: integer 


CREATE TABLE PROJECT(EmployeeID int primary key auto_increment,Fullname varchar(50) not null,
					 Gender varchar(10) check(gender in("Male", "Female")),ManagerID int);
INSERT INTO PROJECT(EmployeeID,Fullname,Gender,ManagerID) VALUES(1,"Pranaya","Male",3),
						                                        (2,"Priyanka","Female",1),
                                                                (3,"Preety","Female",NULL),
                                                                (4,"Anurag","Male",1),
                                                                (5,"Sambit","Male",1),
                                                                (6,"Rajesh","Male",3),
                                                                (7,"Hina","Female",3);
SELECT *FROM PROJECT;
SELECT A.Fullname AS ManagerName,B.Fullname as EmployeeName 
from Project as A JOIN Project as B ON A.EmployeeID=B.ManagerID;





#-----------------------------------------------------  Q7-DDL COMMANDS---------------------------------------------------------------------------------------
#Create table facility. Add the below fields into it.
#	Facility_ID
#	Name
#	State
#	Country
#i) Alter the table by adding the primary key and auto increment to Facility_ID column.
#ii) Add a new column city after name with data type as varchar which should not accept any null values.

create table facility(Facility_ID int not null,
                      Name varchar(100),
                      State varchar(100),
                      Country varchar(100));

alter table facility 
MODIFY COLUMN Facility_ID int not null primary key auto_increment;

alter table facility 
ADD COLUMN City varchar(100) not null after name;

select * from facility;
describe facility;

#  ------------------------------------------------ Q8-VIEWS-------------------------------------------------------------------------------------
#a. Create a view named product_category_sales that provides insights into sales performance by product category. 
#This view should include the following information:
#productLine: The category name of the product (from the ProductLines table).
#total_sales: The total revenue generated by products within that category 
#(calculated by summing the orderDetails.quantity * orderDetails.priceEach for each product in the category).
#number_of_orders: The total number of orders containing products from that category


select *from products; #p1
select *from orders; #o1
select *from orderdetails; #o2
select *from productlines; #p2

 create view product_category_sales  as 
 select p2.productLine,
 sum(o2.quantityordered*o2.priceeach) as total_sales,
 count(distinct o1.orderNumber) as no_of_orders
 from productlines as p2 join products as p1 on p2.productLine=p1.productLine 
 join orderdetails as o2 on o2.productCode=p1.productCode
 join orders as o1 on o1.ordernumber=o2.orderNumber
 group by p2.productline;


select *from product_category_sales;



#  -------------------------------------------------- Q9-STORED PROCEDURES--------------------------------------------------------------------------------------
# Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. 
#Format the total amount to nearest thousand unit (K)
#Tables: Customers, Payments

select *from customers;
select *from Payments;

DELIMITER $$
USE `classicmodels`$$
CREATE PROCEDURE `Get_country_payments`(in yr int,in con varchar(30))
BEGIN
select year(p.paymentdate) as year , c.country,
concat(format(round(sum(p.amount/1000)),0),"K") as Totalamoun
from customers as c join payments as p on c.customerNumber=p.customerNumber
where year(p.paymentdate)=yr and c.country=con
group by year(p.paymentdate),c.country;
END$$

DELIMITER ;
;
call classicmodels.Get_country_payments(2003, 'France');



# ------------------------------------------------------------  Q10-WINDOW FUNCTIONS--------------------------------------------


#a ) Using customers and orders tables, rank the customers based on their order frequency

SELECT *FROM CUSTOMERS;
SELECT * FROM ORDERS;

SELECT customerName, order_count,
       DENSE_RANK() OVER (ORDER BY order_count DESC) AS order_frequency_rnk
FROM (
    SELECT c.customerName,
           COUNT(o.orderNumber) AS order_count
    FROM Customers AS c
    JOIN Orders AS o ON c.customerNumber = o.customerNumber
    GROUP BY c.customerName
) AS customer_orders
ORDER BY order_frequency_rnk;



#B----------------------
#Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. 
#Format the YoY values in no decimals and show in % sign.



SELECT *FROM ORDERS;

SELECT 
    YEAR(orderdate) AS Year,
    MONTHNAME(orderdate) AS Monthname,
    COUNT(ordernumber) AS Total_Orders,
    ifnull(concat(ROUND((count(ordernumber) - lag(count(ordernumber),1,0) 
    over (partition by year(orderdate) ))/lag((count(ordernumber)),1,0) 
over (partition by year(orderdate)) *100,0),"%"),"null") as YOY 
FROM 
    orders
GROUP BY 
    YEAR(orderdate) ,monthname(orderdate)
ORDER BY 
  year,field(monthname, 'January', 'February', 'March', 'April', 'May', 'June', 
                'July', 'August', 'September', 'October', 'November', 'December');
 


# ------------------------------------------------------  Q11-SUBQUERIES----------------------------------------------------------------------------
## Find out how many product lines are there for which the buy price value is greater than the average of buy price value. 
#Show the output as product line and its count.


SELECT * FROM PRODUCTS;

SELECT productLine,count(productline) as Total FROM PRODUCTS AS P 
WHERE buyPrice>(SELECT AVG(buyPrice) FROM PRODUCTS)
group by productLine
order by Total desc;
       

# ---------------------------------------------------------  Q12-ERROR HANDLING------------------------------------------------------------------------------------
	#Create the table Emp_EH. Below are its fields.
#	EmpID (Primary Key)
#	EmpName
#	EmailAddress
#Create a procedure to accept the values for the columns in Emp_EH. Handle the error using exception handling concept. Show the message as “Error occurred” in case of anything wrong.


create table Emp_EH (EmpID INT PRIMARY KEY ,EmpName varchar(100),EmailAddress varchar(100));

DELIMITER $$
USE `classicmodels`$$
CREATE PROCEDURE `ERROR HANDLING`(IN EID INT,IN EName VARCHAR(100),IN Email VARCHAR(100))
BEGIN
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
   SELECT 'Error occured' AS error_message;
END;
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (EID, EName, Email);
    SELECT 'Employee inserted successfully' AS success_message;
END$$

DELIMITER ;
;

select * from Emp_EH;



# -----------------------------------------------------------------  Q13-TRIGGERS-------------------------------------------------------------------------------------
#Create the table Emp_BIT. Add below fields in it.
#	Name
#	Occupation
#	Working_date
#	Working_hours
#Insert the data as shown in below query.
#INSERT INTO Emp_BIT VALUES
#('Robin', 'Scientist', '2020-10-04', 12),  
#('Warner', 'Engineer', '2020-10-04', 10),  
#('Peter', 'Actor', '2020-10-04', 13),  
#('Marco', 'Doctor', '2020-10-04', 14),  
#('Brayden', 'Teacher', '2020-10-04', 12),  ('Antonio', 'Business', '2020-10-04', 11);  
 #Create before insert trigger to make sure any new value of Working_hours, if it is negative, then it should be inserted as positive.


create table Emp_BIT(NAME VARCHAR(100),
                     OCCUPATION VARCHAR(100),
                     WORKING_DATE DATE,
                     WORKING_HOURS INT);
Select * from Emp_BIT;
Insert into Emp_BIT VALUES ('Robin','Scientist','2020-10-04',12);

Insert into Emp_BIT VALUES('Warner', 'Engineer', '2020-10-04', 10),  
                          ('Peter', 'Actor', '2020-10-04', 13),
                          ('Marco', 'Doctor', '2020-10-04', 14),  
                          ('Brayden', 'Teacher', '2020-10-04', 12),  
                          ('Antonio', 'Business', '2020-10-04', 11);
                          
  Insert into Emp_BIT VALUES('Lily','Analyst','2020-10-04',-10);  

Select * from Emp_BIT;

 # END
 
 
 
 



