DROP SCHEMA IF EXISTS formula_1;

-- creating schema
CREATE SCHEMA formula_1;
USE formula_1;

-- creating tables

-- constructors
CREATE TABLE constructors 
(constructorId INTEGER NOT NULL,
constructorRef VARCHAR(255) NOT NULL,
constructor_name  VARCHAR(255) NOT NULL,
natonality  VARCHAR(255) NOT NULL,
url VARCHAR(255) NOT NULL,
PRIMARY KEY(constructorId));

CREATE TABLE drivers 
(driver_id INTEGER NOT NULL,
driver_ref VARCHAR(255) NOT NULL,
number  INTEGER,
code  VARCHAR(255),
first_name VARCHAR(255) NOT NULL,
last_name VARCHAR(255) NOT NULL,
dob DATE NOT NULL,
nationality VARCHAR(255),
url VARCHAR (255),
PRIMARY KEY(driver_id));


-- this should be ON
SHOW VARIABLES LIKE "local_infile";
-- SET GLOBAL local_infile = 'ON';


-- Data loading in
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/HW1/formula_1_data/constructors.csv'
INTO TABLE constructors
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(constructorId, constructorRef, constructor_name, natonality, url);

SET @save := @@sql_mode;
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/HW1/formula_1_data/drivers.csv'
INTO TABLE drivers
CHARACTER SET utf8mb4 -- TODO: handle somehow invalid characters
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(driver_id, driver_ref, number, code, first_name, last_name, dob, nationality, url);
SET @@sql_mode := @save;

SELECT * FROM constructors;

