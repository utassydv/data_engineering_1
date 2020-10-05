-- CASE

DROP SCHEMA IF EXISTS birdstrikes;
DROP SCHEMA IF EXISTS formula1;

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

SELECT * FROM birdstrikes.birdstrikes;


SELECT aircraft, airline, cost, 
    CASE 
        WHEN cost  = 0
            THEN 'NO COST'
        WHEN  cost >0 AND cost < 100000
            THEN 'MEDIUM COST'
        ELSE 
            'HIGH COST'
    END
    AS cost_category   
FROM  birdstrikes
ORDER BY cost_category;


-- Exercise1: Do the same with speed. If speed is NULL or speed < 100 create a "LOW SPEED" category, otherwise, mark as "HIGH SPEED". Use IF instead of CASE!
SELECT  aircraft, airline, speed, 
IF(speed  IS NULL OR speed < 100, 'LOW SPEED', 'HIGH SPEED') 
AS speed_category   
FROM  birdstrikes
ORDER BY speed_category DESC;
-- COUNT

-- COUNT(*)
SELECT COUNT(*) FROM birdstrikes;

-- COUNT(column)
SELECT COUNT(reported_date) FROM birdstrikes;
-- counting the not null ones


-- DISTINCT

-- distinct states
SELECT DISTINCT(state) FROM birdstrikes;

-- how many distinct states we have
SELECT COUNT(DISTINCT(state)) FROM birdstrikes;


-- MAX, AVG, SUM

-- she sum of all repair costs of birdstrikes accidents
SELECT SUM(cost) FROM birdstrikes;

-- speed in this database is measured in KNOTS. Let's transform to KMH. 1 KNOT = 1.852 KMH
SELECT (AVG(speed)*1.852) as avg_kmh FROM birdstrikes;

-- how many observation days we have in birdstrikes
SELECT DATEDIFF(MAX(reported_date),MIN(reported_date)) from birdstrikes;

-- distinct aircraft
SELECT distinct(aircraft) FROM birdstrikes;
SELECT count(distinct(aircraft)) FROM birdstrikes;
-- 3(2)

-- Exercise3: What was the lowest speed of aircrafts starting with 'H'
SELECT MIN(speed) as lowest_speed FROM birdstrikes WHERE aircraft LIKE 'H%';
-- 9
-- GROUP BY

-- one group: What is the highest speed by aircraft type?
SELECT MAX(speed), aircraft FROM birdstrikes GROUP BY aircraft;

-- multiple groups: Which state for which aircraft type paid the most repair cost?
SELECT state, aircraft, SUM(cost) AS sum FROM birdstrikes WHERE state !='' GROUP BY state, aircraft ORDER BY sum DESC;

-- Exercise4: Which phase_of_flight has the least of incidents?
SELECT phase_of_flight, COUNT(phase_of_flight) AS count FROM birdstrikes GROUP BY phase_of_flight ORDER BY count;
-- Taxi

-- Exercise5: What is the rounded highest average cost by phase_of_flight?
SELECT phase_of_flight, ROUND(AVG(cost)) AS avg_cost FROM birdstrikes GROUP BY phase_of_flight ORDER BY avg_cost;
-- 54673


-- HAVING

-- lets say you have average speed by state
SELECT state, AVG(speed) AS avg_speed FROM birdstrikes GROUP BY state ;

-- and you want only avg_speed=50
SELECT state,AVG(speed) AS avg_speed FROM birdstrikes GROUP BY state WHERE ROUND(avg_speed) = 50;

SELECT state,AVG(speed) AS avg_speed FROM birdstrikes GROUP BY state HAVING ROUND(avg_speed) = 50;

-- before aggragetion filter
SELECT state,AVG(speed) AS avg_speed FROM birdstrikes WHERE state='Idaho' GROUP BY state HAVING ROUND(avg_speed) = 50;

-- Exercise6: What the highest AVG speed of the states with names less than 5 characters?
SELECT state, AVG(speed) AS avg_speed FROM birdstrikes GROUP BY state HAVING LENGTH(state) < 5 ORDER BY avg_speed;  
-- 2862.5000
