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
SET GLOBAL local_infile = 'ON';

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

-- Exercise1: Do the same with speed. If speed is NULL or speed < 100 create a "LOW SPEED" category, otherwise, mark as "HIGH SPEED". Use IF instead of CASE!
SELECT  aircraft, airline, speed, 
IF(speed  IS NULL OR speed < 100, 'LOW SPEED', 'HIGH SPEED') 
AS speed_category   
FROM  birdstrikes
ORDER BY speed_category DESC;


-- Excersise2: 
SELECT distinct(aircraft) FROM birdstrikes;
SELECT count(distinct(aircraft)) FROM birdstrikes;
-- 3

-- Exercise3: What was the lowest speed of aircrafts starting with 'H'
SELECT MIN(speed) as lowest_speed FROM birdstrikes WHERE aircraft LIKE 'H%';
-- 9

-- Exercise4: Which phase_of_flight has the least of incidents?
SELECT phase_of_flight, COUNT(phase_of_flight) AS count FROM birdstrikes GROUP BY phase_of_flight ORDER BY count;
-- Taxi

-- Exercise5: What is the rounded highest average cost by phase_of_flight?
SELECT phase_of_flight, ROUND(AVG(cost)) AS avg_cost FROM birdstrikes GROUP BY phase_of_flight ORDER BY avg_cost;
-- 54673


-- Exercise6: What the highest AVG speed of the states with names less than 5 characters?
SELECT state, AVG(speed) AS avg_speed FROM birdstrikes GROUP BY state HAVING LENGTH(state) < 5 ORDER BY avg_speed;  
SELECT state, AVG(speed) AS avg_speed FROM birdstrikes WHERE LENGTH(state) < 5 GROUP BY state  ORDER BY avg_speed; -- prefered way, it is faster, first filter, then agregate
-- 2862.5000