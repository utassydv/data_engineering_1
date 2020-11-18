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
dob DATE,
nationality VARCHAR(255),
url VARCHAR (255),
PRIMARY KEY(driver_id));

CREATE TABLE races 
(race_id INTEGER NOT NULL,
race_year INTEGER NOT NULL,
race_round INTEGER NOT NULL,
circuit_id INTEGER NOT NULL,
grand_prix_name VARCHAR(255) NOT NULL,
race_date VARCHAR(255) NOT NULL,
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

-- create log_table
CREATE TABLE log_table (log_table varchar(100) NOT NULL);

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
(race_id, race_year, race_round, circuit_id, grand_prix_name, race_date, race_time, url);

LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/Term DE1/formula_1_data/circuits.csv'
INTO TABLE circuits
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(circuit_id, circuit_ref, circuit_name, location, country, latitude, longitude, altitude,url);

-- SELECT * FROM results;

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
		race.race_year, 
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


-- creating f1_table for analysis with calling the following stored procedure
CALL CreateF1Table();

-- SELECT * FROM f1_table;


-- create a trigger wich is executed after every insert in the races table
-- it refreshes the f1_table, and filling it up with the new results
DROP TRIGGER IF EXISTS after_race_insert; 
DELIMITER $$
CREATE TRIGGER after_race_insert
AFTER INSERT ON races FOR EACH ROW
BEGIN
   	-- log the order number of the newley inserted order
    INSERT INTO log_table SELECT CONCAT('new race id: ', NEW.race_id);
   
	-- archive the order and assosiated table entries to order_store
  	INSERT INTO f1_table
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
		race.race_year, 
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
		USING(circuit_id)
	WHERE race_id = NEW.race_id;
END $$
DELIMITER ;



-- To test the trigger, for that we should insert a row into the races table
-- For that it is nice if we have some results as well, 
-- therefore I am creating a stored procedure, to insert a new race, and insert 20 new results ( 20 drivers results)
-- (note: the value of the results are kind of dummy, it is only for testing the trigger)
DROP PROCEDURE IF EXISTS InsertARace;
DELIMITER $$
CREATE PROCEDURE InsertARace(IN next_race_id INTEGER, IN next_result_id INTEGER)
BEGIN
    DECLARE loop_iterator INT;
    
    SET loop_iterator = 0;
    
        
	myloop: LOOP 
			
		SET  loop_iterator = loop_iterator + 1;
        SET  next_result_id = next_result_id + 1;
        
           
        INSERT INTO results VALUES(next_result_id, next_race_id, loop_iterator, loop_iterator, 22, 1, loop_iterator, '', loop_iterator, loop_iterator);
		
		
        IF  (loop_iterator= 20) THEN
			LEAVE myloop;
         	END  IF;
            
	END LOOP myloop;
    
    INSERT INTO races VALUES(next_race_id, 2020, 1, 11, 'CEU' ,'',  '', 'www.ceu.com');
    
END$$
DELIMITER ;


-- can be called only once, to test trigger, for the second run, starting id-s should be modified!
-- input parameters: next race_id, next_resut_id
-- SELECT * from races ORDER BY race_id DESC; -- last id was 1009
-- SELECT * from results ORDER BY result_id DESC; -- last id was 23781

CALL InsertARace(1010, 23781); 
CALL InsertARace(1011, 23801); 

SELECT * FROM log_table;
SELECT * FROM f1_table ORDER BY result_id DESC;
SELECT * FROM f1_table;

-- ------------------------------------------------------------------------------------------
-- DATA MARTS

DROP VIEW IF EXISTS HungarianGPs;
CREATE VIEW `HungarianGPs` AS
SELECT * FROM f1_table WHERE f1_table.country = 'Hungary';

DROP VIEW IF EXISTS FerrariResults;
CREATE VIEW `FerrariResults` AS
SELECT * FROM f1_table WHERE f1_table.constructor_name = 'Ferrari';

DROP VIEW IF EXISTS FerrariResults;
CREATE VIEW `FerrariResults` AS
SELECT * FROM f1_table WHERE f1_table.constructor_name = 'Ferrari';

-- a stored procedure, that can be used, to get a view on any driver according to the driver_ref
DROP PROCEDURE IF EXISTS GetDriverView;
DELIMITER $$
CREATE PROCEDURE GetDriverView(IN driver VARCHAR(100))
BEGIN
    
    DROP VIEW IF EXISTS DriverView;
	CREATE VIEW `DriverView` AS
	SELECT * FROM f1_table WHERE f1_table.driver_ref = driver;
    
END$$
DELIMITER ;

CALL GetDriverView('vettel');








