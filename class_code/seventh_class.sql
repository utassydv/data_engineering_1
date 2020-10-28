DROP SCHEMA IF EXISTS birdstrikes;

CREATE SCHEMA birdstrikes;
USE birdstrikes ;

-- create an empty table
CREATE TABLE birdstrikes 
(id INTEGER NOT NULL,
aircraft VARCHAR(32),
flight_date DATE NOT NULL,
damage VARCHAR(16) NOT NULL,
airline VARCHAR(255) NOT NULL,
state VARCHAR(255),
phase_of_flight VARCHAR(32),
reported_date DATE,
bird_size VARCHAR(16),
cost INTEGER NOT NULL,
speed INTEGER,
PRIMARY KEY(id));

-- this should be ON
SHOW VARIABLES LIKE "local_infile";



-- load data into that table (change the path if needed)
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/official_repos/DE1SQL/SQL1/birdstrikes_small.csv'
INTO TABLE birdstrikes
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, aircraft, flight_date, damage, airline, state, phase_of_flight, @v_reported_date, bird_size, cost, @v_speed)
SET
speed = nullif(@v_speed, ''),
reported_date = nullif(@v_reported_date, '');


CREATE TABLE birdstrikes2 LIKE birdstrikes;

INSERT INTO birdstrikes2 SELECT * FROM birdstrikes where id=10 ;

SELECT * FROM birdstrikes2;


-- For insert user the format like: INSERT INTO bla SELECT blabla

USE classicmodels;
   
DROP TRIGGER IF EXISTS after_order_insert; 

DELIMITER $$
CREATE TRIGGER after_order_insert
AFTER INSERT ON orderdetails FOR EACH ROW
BEGIN
   	-- log the order number of the newley inserted order
    INSERT INTO messages SELECT CONCAT('new orderNumber: ', NEW.orderNumber);
   
	-- archive the order and assosiated table entries to order_store
  	INSERT INTO product_sales
	SELECT 
	   orders.orderNumber AS SalesId, 
	   orderdetails.priceEach AS Price, 
	   orderdetails.quantityOrdered AS Unit,
	   products.productName AS Product,
	   products.productLine As Brand,
	   customers.city As City,
	   customers.country As Country,   
	   orders.orderDate AS Date,
	   WEEK(orders.orderDate) as WeekOfYear
	FROM orders
	INNER JOIN orderdetails USING (orderNumber)
	INNER JOIN products USING (productCode)
	INNER JOIN customers USING (customerNumber)
	WHERE orderNumber = NEW.orderNumber
	ORDER BY orderNumber, orderLineNumber;
END $$
DELIMITER ;


SELECT * FROM product_sales ORDER BY SalesId;

SELECT COUNT(*) FROM product_sales;

TRUNCATE messages;

INSERT INTO orders  VALUES(16,'2020-10-01','2020-10-01','2020-10-01','Done','',131);
INSERT INTO orderdetails  VALUES(16,'S18_1749','1','10',1);

SELECT * FROM messages;

SELECT * FROM product_sales WHERE product_sales.SalesId = 16;

-- DELETE FROM classicmodels.product_sales WHERE SalesId=16;
-- DELETE FROM classicmodels.orderdetails WHERE orderNumber=16;
-- DELETE FROM classicmodels.orders WHERE orderNumber=16;


-- VIEWS AS DATAMARTS

DROP VIEW IF EXISTS Vintage_Cars;

CREATE VIEW `Vintage_Cars` AS
	SELECT * FROM product_sales WHERE product_sales.Brand = 'Vintage Cars';

SELECT * FROM Vintage_Cars;

DROP VIEW IF EXISTS USA;

CREATE VIEW `USA` AS
	SELECT * FROM product_sales WHERE country = 'USA';
    
SELECT * FROM USA;

-- Exercise2: Create a view, which contains product_sales rows of 2003 and 2005. How many row has the resulting view?



