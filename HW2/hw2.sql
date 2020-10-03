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


-- Data loading in
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/official_repos/DE1SQL/SQL1/birdstrikes_small.csv'
INTO TABLE birdstrikes
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, aircraft, flight_date, damage, airline, state, phase_of_flight, @v_reported_date, bird_size, cost, @v_speed)
SET
speed = nullif(@v_speed, ''),
reported_date = nullif(@v_reported_date, '');

-- Exercise1: What state figures in the 145th line of our database?
SELECT state FROM birdstrikes LIMIT 144,1;
-- Tennessee

-- Exercise2: What is flight_date of the latest birstrike in this database?
SELECT flight_date FROM birdstrikes ORDER BY flight_date DESC LIMIT 1;
-- 2000-04-18 april 

-- Exercise3: What was the cost of the 50th most expensive damage?
SELECT DISTINCT cost FROM birdstrikes ORDER BY cost DESC LIMIT 49,1;
-- 5345


-- Exercise4: What state figures in the 2nd record, if you filter out all records which have no state and no bird_size specified?
SELECT state FROM birdstrikes WHERE state IS NOT NULL AND bird_size IS NOT NULL LIMIT 1,1;
-- '' 

-- Exercise5:  How many days elapsed between the current date and the flights happening in week 52, for incidents from Colorado? (Hint: use NOW, DATEDIFF, WEEKOFYEAR)
SELECT  state, WEEKOFYEAR(flight_date), flight_date, NOW(), DATEDIFF(NOW(), flight_date) AS time_since FROM birdstrikes WHERE WEEKOFYEAR(flight_date) = 52 AND state = 'Colorado';
-- 7581 on 2020-10-03


