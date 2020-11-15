-- preparation part
DROP SCHEMA IF EXISTS formula_1;

-- ------------------------------------------------------------------------------------------
-- OPERATIONAL LAYER
-- creating schema
CREATE SCHEMA formula_1;
USE formula_1;

-- creating tables

CREATE TABLE results 
(result_id INTEGER NOT NULL,
race_id INTEGER NOT NULL,
driver_id INTEGER NOT NULL,
constructor_id INTEGER NOT NULL,
num INTEGER NOT NULL,
grid INTEGER NOT NULL,
pos INTEGER,
position_text VARCHAR(255) NOT NULL,
position_order INTEGER NOT NULL,
points INTEGER NOT NULL,
PRIMARY KEY(result_id));

CREATE TABLE constructors 
(constructor_id INTEGER NOT NULL,
constructor_ref VARCHAR(255) NOT NULL,
constructor_name  VARCHAR(255) NOT NULL,
natonality  VARCHAR(255) NOT NULL,
url VARCHAR(255) NOT NULL,
PRIMARY KEY(constructor_id));

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

CREATE TABLE races 
(race_id INTEGER NOT NULL,
year INTEGER NOT NULL,
round INTEGER NOT NULL,
circuit_id INTEGER NOT NULL,
grand_prix_name VARCHAR(255) NOT NULL,
date VARCHAR(255) NOT NULL,
race_time VARCHAR(255) NOT NULL,
url VARCHAR(255) NOT NULL,
PRIMARY KEY(race_id));

CREATE TABLE circuits 
(circuit_id INTEGER NOT NULL,
circuit_ref VARCHAR(255) NOT NULL,
circuit_name VARCHAR(255) NOT NULL,
location VARCHAR(255) NOT NULL,
country VARCHAR(255) NOT NULL,
latitude VARCHAR(255) NOT NULL,
longitude VARCHAR(255) NOT NULL,
altitude INTEGER,
url VARCHAR(255) NOT NULL,
PRIMARY KEY(circuit_id));

-- mac: this should be ON
SHOW VARIABLES LIKE "local_infile";
-- if it is off, use the line below to turn it on
-- SET GLOBAL local_infile = 'ON';


-- Data loading in
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/Term DE1/formula_1_data/results.csv'
INTO TABLE results
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(result_id, race_id, driver_id, constructor_id, num, grid, pos, position_text, position_order, points);

LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/Term DE1/formula_1_data/constructors.csv'
INTO TABLE constructors
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(constructor_id, constructor_ref, constructor_name, natonality, url);

LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/Term DE1/formula_1_data/drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(driver_id, driver_ref, number, code, first_name, last_name, dob, nationality, url);

LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/Term DE1/formula_1_data/races.csv'
INTO TABLE races
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(race_id, year, round, circuit_id, grand_prix_name, date, race_time, url);

LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/Term DE1/formula_1_data/circuits.csv'
INTO TABLE circuits
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(circuit_id, circuit_ref, circuit_name, location, country, latitude, longitude, altitude,url);

SELECT * FROM results;

-- ------------------------------------------------------------------------------------------
-- ETL PIPELINE
    
-- joining tables, to have a table which is convenient to analyse
-- using a stored precedure to to that:

-- creating a table with the joint tables:

DROP PROCEDURE IF EXISTS CreateF1Table;
DELIMITER //

CREATE PROCEDURE CreateF1Table()
BEGIN
	DROP TABLE IF EXISTS f1_table;

	CREATE TABLE f1_table AS
	SELECT 
		r.result_id, 
		d.first_name, 
		d.last_name, 
		d.code, 
		d.driver_ref, 
		c.constructor_id, 
		c.constructor_name, 
		r.grid, 
		r.pos,
		r.position_text, 
		r.position_order, 
		race.grand_prix_name, 
		race.year, 
		circ.country
	FROM 
		results r
	INNER JOIN drivers d
		USING(driver_id)
	INNER JOIN constructors c
		USING(constructor_id)
	INNER JOIN races race
		USING(race_id)
	INNER JOIN circuits circ
		USING(circuit_id);
		
END //
DELIMITER ;

CALL CreateF1Table();
    
-- DATA MARTS



