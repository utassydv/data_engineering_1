DROP SCHEMA IF EXISTS formula_1;

-- creating schema
CREATE SCHEMA formula_1;
USE formula_1;

-- creating tables

-- constructors
CREATE TABLE constructors 
(constructor_id INTEGER NOT NULL,
constructor_ref VARCHAR(255) NOT NULL,
constructor_name  VARCHAR(255) NOT NULL,
natonality  VARCHAR(255) NOT NULL,
url VARCHAR(255) NOT NULL,
PRIMARY KEY(constructor_id));

-- drivers
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

-- results
CREATE TABLE results 
(result_id INTEGER NOT NULL,
race_id INTEGER NOT NULL,
driver_id INTEGER NOT NULL,
constructor_id INTEGER NOT NULL,
number INTEGER NOT NULL,
grid INTEGER NOT NULL,
position INTEGER NOT NULL,
position_text VARCHAR(255) NOT NULL,
position_order INTEGER NOT NULL,
points INTEGER NOT NULL,
PRIMARY KEY(result_id));

-- races
CREATE TABLE races 
(race_id INTEGER NOT NULL,
year INTEGER NOT NULL,
round INTEGER NOT NULL,
circuit_id INTEGER NOT NULL,
circuit_name VARCHAR(255) NOT NULL,
date VARCHAR(255) NOT NULL,
race_time VARCHAR(255) NOT NULL,
url VARCHAR(255) NOT NULL,

PRIMARY KEY(race_id));


-- this should be ON
SHOW VARIABLES LIKE "local_infile";
-- SET GLOBAL local_infile = 'ON';


-- Data loading in
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/Term DE1/formula_1_data/results.csv'
INTO TABLE results
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(result_id, race_id, driver_id, constructor_id, number, grid, position, position_text, position_order, points);

LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/Term DE1/formula_1_data/constructors.csv'
INTO TABLE constructors
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(constructor_id, constructor_ref, constructor_name, natonality, url);


-- .csv files should be coded in utf8, (in excel save-as can do the conversion)
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/HW1/formula_1_data/drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(driver_id, driver_ref, number, code, first_name, last_name, dob, nationality, url);

-- .csv files should be coded in utf8, (in excel save-as can do the conversion)
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/HW1/formula_1_data/races.csv'
INTO TABLE races
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(race_id, year, round, circuit_id, circuit_name, date, race_time, url);

SELECT * FROM races;

    
SELECT r.result_id, d.first_name, d.last_name, d.code, d.driver_ref, c.constructor_id, c.constructor_name, r.grid, r.position, r.position_text, r.position_order
FROM  results r
INNER JOIN drivers d
	USING(driver_id)
INNER JOIN constructors c
	USING(constructor_id)


