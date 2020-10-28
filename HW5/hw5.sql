USE classicmodels;

-- Creating a table
CREATE TABLE area_codes 
(city VARCHAR(255)  NOT NULL,
AreaCode INTEGER NOT NULL,
PRIMARY KEY(city));

-- this should be ON
SHOW VARIABLES LIKE "local_infile";
-- SET GLOBAL local_infile = 'ON';

TRUNCATE area_codes;
-- Data loading in
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/HW5/HW5.csv'
INTO TABLE area_codes
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(city, AreaCode);


DROP PROCEDURE IF EXISTS FixUSPhones; 
DELIMITER $$

CREATE PROCEDURE FixUSPhones ()
BEGIN
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE phone varchar(50) DEFAULT "x";
	DECLARE customerNumber INT DEFAULT 0;
	DECLARE country varchar(50) DEFAULT "";
    DECLARE city varchar(50) DEFAULT "";
    DECLARE areacode varchar(50) DEFAULT "";

	-- declare cursor for customer
	DECLARE curPhone
		CURSOR FOR 
            SELECT customers.customerNumber, customers.phone, customers.country, customers.city FROM classicmodels.customers;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

	OPEN curPhone;
    
	-- create a copy of the customer table 
	DROP TABLE IF EXISTS classicmodels.fixed_customers;
	CREATE TABLE classicmodels.fixed_customers LIKE classicmodels.customers;
	INSERT fixed_customers SELECT * FROM classicmodels.customers;

	TRUNCATE messages;
    
	fixPhone: LOOP
		FETCH curPhone INTO customerNumber,phone, country, city;
		IF finished = 1 THEN 
			LEAVE fixPhone;
		END IF;
		 
		INSERT INTO messages SELECT CONCAT('country is: ', country, ' and phone is: ', phone);
         
		IF country = 'USA'  THEN
			IF phone NOT LIKE '+%' THEN
				IF LENGTH(phone) = 10 THEN 
					SET  phone = CONCAT('+1',phone);
					UPDATE classicmodels.fixed_customers 
						SET fixed_customers.phone=phone 
							WHERE fixed_customers.customerNumber = customerNumber;
				END IF;    
                IF LENGTH(phone) = 7 THEN
					SET areacode = (SELECT area_codes.AreaCode FROM area_codes WHERE area_codes.city = city);
					SET  phone = CONCAT('+1',areacode,phone);
					UPDATE classicmodels.fixed_customers 
						SET fixed_customers.phone=phone 
							WHERE fixed_customers.customerNumber = customerNumber;
				END IF;   
			END IF;
		END IF;

	END LOOP fixPhone;
	CLOSE curPhone;

END$$
DELIMITER ;

CALL FixUSPhones();

SELECT * FROM fixed_customers WHERE country = 'USA';

SELECT * FROM messages;