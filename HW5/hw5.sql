use classicmodels;

-- basic
DROP PROCEDURE IF EXISTS GetAllProducts;

DELIMITER //

CREATE PROCEDURE GetAllProducts()
BEGIN
	SELECT *  FROM products;
END //

DELIMITER ;

CALL GetAllProducts();

-- IN
DROP PROCEDURE IF EXISTS GetOfficeByCountry;

DELIMITER //

CREATE PROCEDURE GetOfficeByCountry(
	IN countryName VARCHAR(255)
)
BEGIN
	SELECT * 
 		FROM offices
			WHERE country = countryName;
END //
DELIMITER ;

CALL GetOfficeByCountry('USA'); 
CALL GetOfficeByCountry('France'); 
CALL GetOfficeByCountry();

-- Exercise1: Create a stored procedure which displays the first X entries of payment table. X is IN parameter for the procedure.
-- IN
DROP PROCEDURE IF EXISTS GetXPayment;

DELIMITER //

CREATE PROCEDURE GetXPayment(IN number INTEGER)
BEGIN
	SELECT * FROM payments LIMIT 0,number;
END //
DELIMITER ;


CALL GetXPayment(5);

-- SELECT * FROM payments;


-- OUT
DROP PROCEDURE IF EXISTS GetOrderCountByStatus;

DELIMITER $$

CREATE PROCEDURE GetOrderCountByStatus (
	IN  orderStatus VARCHAR(25),
	OUT total INT
)
BEGIN
	SELECT COUNT(orderNumber)
	INTO total
	FROM orders
	WHERE status = orderStatus;
END$$
DELIMITER ;

CALL GetOrderCountByStatus('Shipped',@total);
SELECT @total;

-- Exercise2: Create a stored procedure which returns the amount for Xth entry of payment table. X is IN parameter for the procedure. Display the returned amount.
DROP PROCEDURE IF EXISTS GetAmount;
DELIMITER $$
CREATE PROCEDURE GetAmount (
	IN  X INT,
	OUT amount_out DOUBLE
)
BEGIN
    SET X = X-1;
    SELECT amount INTO amount_out FROM payments LIMIT X,1;
END$$
DELIMITER ;

CALL GetAmount(1,@amount);
SELECT @amount;

SELECT * from payments;

-- INOUT

DROP PROCEDURE IF EXISTS SetCounter;

DELIMITER $$

CREATE PROCEDURE SetCounter(
	INOUT counter INT,
    	IN inc INT
)
BEGIN
	SET counter = counter + inc;
END$$
DELIMITER ;

SET @counter = 1;
CALL SetCounter(@counter,1); 
SELECT @counter;
CALL SetCounter(@counter,1); 
SELECT @counter;
CALL SetCounter(@counter,-1); 
SELECT @counter;

-- IF

DROP PROCEDURE IF EXISTS GetCustomerLevel;

DELIMITER $$

CREATE PROCEDURE GetCustomerLevel(
    	IN  pCustomerNumber INT, 
    	OUT pCustomerLevel  VARCHAR(20)
)
BEGIN
	DECLARE credit DECIMAL DEFAULT 0;

	SELECT creditLimit 
		INTO credit
			FROM customers
				WHERE customerNumber = pCustomerNumber;

	IF credit > 50000 THEN
		SET pCustomerLevel = 'PLATINUM';
	ELSE
		SET pCustomerLevel = 'NOT PLATINUM';
	END IF;
END$$
DELIMITER ;

select * from payments;
CALL GetCustomerLevel(447, @level);
SELECT @level;

-- Exercise3:  Create a stored procedure which returns category of a given row. Row number is IN parameter, while category is OUT parameter. Display the returned category. CAT1 - amount > 100.000, CAT2 - amount > 10.000, CAT3 - amount <= 10.000
DROP PROCEDURE IF EXISTS GetCategory;
DELIMITER $$

CREATE PROCEDURE GetCategory(IN  row_num INT, OUT row_category  VARCHAR(20) )
BEGIN
	DECLARE am DECIMAL DEFAULT 0;
    set row_num = row_num -1;

	SELECT amount INTO am FROM payments LIMIT row_num,1;

	IF am > 100000 THEN
		SET row_category = 'CAT1';
	ELSEIF am > 10000 THEN
		SET row_category = 'CAT2';
	ELSEIF am <=10000 THEN
		SET row_category = 'CAT3';
	END IF;
    
END$$
DELIMITER ;

SELECT * from payments;

CALL GetCategory(5, @category);
SELECT @category;
