-- to load data just run samledtabase_create.sql from 5class

-- INNER
SELECT * 
FROM products 
INNER JOIN productlines  
ON products.productline = productlines.productline;

-- aliasing
SELECT t1.productLine, t2.textDescription
FROM products t1
INNER JOIN productlines t2 
ON t1.productline = t2.productline;

-- using
SELECT t1.productLine, t2.textDescription
FROM products t1
INNER JOIN productlines t2 
USING(productline); -- shortcut if the keys are the same

-- specific columns
SELECT t1.productLine, t2.textDescription
FROM products t1
INNER JOIN productlines t2 
ON t1.productline = t2.productline;

-- Exercise1: Join all fields of order and orderdetails
SELECT * 
FROM orders 
INNER JOIN orderdetails  
USING(orderNumber);

-- Exercise2: Join all fields of order and orderdetails. Display only orderNumber, status and sum of totalsales (quantityOrdered * priceEach) for each orderNumber.
SELECT 
			t1.orderNumber, 
			t1.status, 
			SUM(t2.quantityOrdered * t2.priceEach)
FROM 
			orders  t1
INNER JOIN orderdetails t2
USING(orderNumber)
GROUP BY ordernumber;


-- Exercise3: We want to how the employees are performing. Join orders, customers and employees and return orderDate,lastName, firstName
SELECT orderDate, lastName, firstName
FROM orders  t1
INNER JOIN customers t2
USING(customerNumber)
INNER JOIN employees t3
ON t2.salesRepEmployeeNumber = t3.EmployeeNumber;


-- SELF

-- Employee table represents a hierarchy, which can be flattened with a self join. The next query displays the Manager, Direct report pairs:
SELECT 
    CONCAT(m.lastName, ', ', m.firstName) AS Manager,
    CONCAT(e.lastName, ', ', e.firstName) AS 'Direct report',
    e.jobTitle
FROM
    employees e
INNER JOIN employees m ON 
    m.employeeNumber = e.reportsTo
ORDER BY 
    Manager;
    
-- Exercise4: Why President is not in the list?
-- He is reporting to null
SELECT 
    CONCAT(m.lastName, ', ', m.firstName) AS Manager,
    CONCAT(e.lastName, ', ', e.firstName) AS 'Direct report',
    e.jobTitle
FROM
    employees e
LEFT JOIN employees m ON 
    m.employeeNumber = e.reportsTo
ORDER BY 
    Manager;

-- LEFT

-- returns customer info and related orders:
SELECT
    c.customerNumber,
    customerName,
    orderNumber,
    status
FROM
    customers c
LEFT JOIN orders o 
    ON c.customerNumber = o.customerNumber;
    
-- compare with INNER join. See count on INNER and LEFT JOIN:    
SELECT
  COUNT(*)
FROM
    customers c
INNER JOIN orders o 
    ON c.customerNumber = o.customerNumber;    

-- difference between LEFT and INNER join: The previous example returns all customers including the customers who have no order. If a customer has no order, the values in the column orderNumber and status are NULL. 

    
-- WHERE 
    
SELECT 
    o.orderNumber, 
    customerNumber, 
    productCode
FROM
    orders o
LEFT JOIN orderDetails 
    USING (orderNumber)
WHERE
    orderNumber = 10123;

-- restricting the end result to that

    
-- ON

-- different meaning, join will be applied only for orderNumber 10123
SELECT 
    o.orderNumber, 
    customerNumber, 
    productCode
FROM
    orders o
LEFT JOIN orderDetails d 
    ON o.orderNumber = d.orderNumber AND 
       o.orderNumber = 10123;
-- joinnig only at 10123


