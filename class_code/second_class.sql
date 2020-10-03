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

CREATE TABLE new_birdstrikes LIKE birdstrikes;
SHOW TABLES;
DESCRIBE new_birdstrikes;
SELECT * FROM new_birdstrikes;

DROP TABLE IF EXISTS new_birdstrikes;

CREATE TABLE employee (id INTEGER NOT NULL, employee_name VARCHAR(255) NOT NULL, PRIMARY KEY(id));
SHOW TABLES;

DESCRIBE employee;
SELECT * FROM employee;

INSERT INTO employee (id,employee_name) VALUES(1,'Student1');
INSERT INTO employee (id,employee_name) VALUES(2,'Student2');
INSERT INTO employee (id,employee_name) VALUES(3,'Student3');

SELECT * FROM employee;

-- this results an error, as id:3 is already exists
INSERT INTO employee (id,employee_name) VALUES(3,'Student4');

UPDATE employee SET employee_name='Arnold Schwarzenegger' WHERE id = '1';

UPDATE employee SET employee_name='The Other Arnold' WHERE id = '2';


SELECT * FROM employee;

DELETE FROM employee WHERE id = 3;
SELECT * FROM employee


TRUNCATE employee;

SELECT * FROM employee;


SELECT damage,cost FROM birdstrikes.birdstrikes;

-- USERS AND PRIVILEGES

-- create user
CREATE USER 'utassy'@'%' IDENTIFIED BY 'utassy';

-- full rights on one table
GRANT ALL ON birdstrikes.employee TO 'utassy'@'%';

-- access only one column
GRANT SELECT (state) ON birdstrikes.birdstrikes TO 'utassy'@'%';

-- delete user
DROP USER 'utassy'@'%';

DESCRIBE birdstrikes;

-- SELECTS

-- create a new column
SELECT *, speed/2 FROM birdstrikes;

-- aliasing
SELECT *, speed/2 AS halfspeed FROM birdstrikes;


-- using Limit
-- list the first 10 records
SELECT * FROM birdstrikes LIMIT 10;

-- list the first 1 record, after the the first 10
SELECT * FROM birdstrikes LIMIT 10,1;

-- Exercise1: What state figures in the 145th line of our database?
SELECT state FROM birdstrikes LIMIT 144,1;
-- Tennessee

-- ordering data
SELECT state, cost FROM birdstrikes ORDER BY cost;
SELECT state, cost FROM birdstrikes ORDER BY state, cost ASC;
SELECT state, cost FROM birdstrikes ORDER BY cost DESC;

-- Exercise2: What is flight_date of the latest birstrike in this database?
SELECT flight_date FROM birdstrikes ORDER BY flight_date DESC LIMIT 1;
-- 2000-04-18 april 

-- unique values
SELECT DISTINCT damage FROM birdstrikes;

-- unique pairs
SELECT DISTINCT airline, damage FROM birdstrikes ORDER BY airline;

-- Exercise3: What was the cost of the 50th most expensive damage?
SELECT DISTINCT cost FROM birdstrikes ORDER BY cost DESC LIMIT 49,1;
-- 5345

-- filtering
SELECT * FROM birdstrikes WHERE state = 'Alabama';

-- DATATYPES

-- COMPARISON OPERATORS

-- VARCHAR

-- LIKE
SELECT DISTINCT state FROM birdstrikes WHERE state LIKE 'A%';

-- note the case (in)sensitivity
SELECT DISTINCT state FROM birdstrikes WHERE state LIKE 'a%';

-- states starting with 'ala'
SELECT DISTINCT state FROM birdstrikes WHERE state LIKE 'ala%';

-- states starting with 'North ' followed by any character, followed by an 'a', followed by anything
SELECT DISTINCT state FROM birdstrikes WHERE state LIKE 'North _a%';

-- states not starting with 'A'
SELECT DISTINCT state FROM birdstrikes WHERE state NOT LIKE 'a%' ORDER BY state;

-- logical operators
SELECT * FROM birdstrikes WHERE state = 'Alabama' AND bird_size = 'Small';
SELECT * FROM birdstrikes WHERE state = 'Alabama' OR state = 'Missouri';

-- IS NOT NULL
-- filtering out nulls and empty strings
SELECT DISTINCT(state) FROM birdstrikes WHERE state IS NOT NULL AND state != '' ORDER BY state;

-- IN
-- what if I need 'Alabama', 'Missouri','New York','Alaska'? Should we concatenate 4 AND filters?
SELECT * FROM birdstrikes WHERE state IN ('Alabama', 'Missouri','New York','Alaska');

-- LENGTH
-- listing states with 5 characters
SELECT DISTINCT(state) FROM birdstrikes WHERE LENGTH(state) = 5;



-- INT

-- speed equals 350
SELECT * FROM birdstrikes WHERE speed = 350;

-- speed equal or more than 25000
SELECT * FROM birdstrikes WHERE speed >= 10000;

-- ROUND, SQRT
SELECT speed, ROUND(SQRT(speed/2) * 10) AS synthetic_speed FROM birdstrikes WHERE SPEED IS NOT NULL;

-- BETWEEN
SELECT * FROM birdstrikes where cost BETWEEN 20 AND 40;


-- Exercise4: What state figures in the 2nd record, if you filter out all records which have no state and no bird_size specified?
SELECT state FROM birdstrikes WHERE state IS NOT NULL AND bird_size IS NOT NULL;
-- '' 

-- DATE
-- date is "2000-01-02"
SELECT * FROM birdstrikes WHERE flight_date = "2000-01-02";

-- all entries where flight_date is between "2000-01-01" AND "2000-01-03"
SELECT * FROM birdstrikes WHERE flight_date >= '2000-01-01' AND flight_date <= '2000-01-03';

-- BETWEEN
SELECT * FROM birdstrikes where flight_date BETWEEN "2000-01-01" AND "2000-01-03";

-- Exercise5:  How many days elapsed between the current date and the flights happening in week 52, for incidents from Colorado? 
-- (Hint: use NOW, DATEDIFF, WEEKOFYEAR)

SELECT  state, WEEKOFYEAR(flight_date), flight_date, NOW(), DATEDIFF(NOW(), flight_date) AS time_since FROM birdstrikes WHERE WEEKOFYEAR(flight_date) = 52 AND state = 'Colorado';
-- 7581 on 2020-10-03


