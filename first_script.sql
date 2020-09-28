CREATE SCHEMA firstdb;

create schema FIRSTDB;

USE firstdb;

DROP SCHEMA firstdb;

DROP SCHEMA IF EXISTS firstdb;


CREATE SCHEMA birdstrikes;
USE birdstrikes;

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