CREATE SCHEMA firstdb;
create schema FIRSTDB;

USE firstdb;

DROP SCHEMA firstdb;
DROP SCHEMA IF EXISTS firstdb;


CREATE SCHEMA firstdb;
USE firstdb;

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
speed INTEGER,PRIMARY KEY(id));

SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE '~/birdstrikes_small.csv' 
INTO TABLE birdstrikes 
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(id, aircraft, flight_date, damage, airline, state, phase_of_flight, @v_reported_date, bird_size, cost, @v_speed)
SET
reported_date = nullif(@v_reported_date, ''),
speed = nullif(@v_speed, '');

LOAD DATA LOCAL INFILE '/birdstrikes_small.csv'
INTO TABLE birdstrikes
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, aircraft, flight_date, damage, airline, state, phase_of_flight, @v_reported_date, bird_size, cost, @v_speed)
SET
speed = nullif(@v_speed, ''),
reported_date = nullif(@v_reported_date, '');

SHOW TABLES;

DESCRIBE birdstrikes;

SELECT * FROM birdstrikes;

SELECT cost FROM birdstrikes;

SELECT airline,cost FROM birdstrikes;