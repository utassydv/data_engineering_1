# Date Engineering Term Project
The goal of this term project is to exercise once more the MySQL statements covered in the course with the dataset about Formula 1 results.

## Dataset
I have used the following "Formula 1 Race Data" dataset to practice my mySQL skills. The kaggle website of the data has a nice explanation about the details of it.

https://www.kaggle.com/cjgdev/formula-1-race-data-19502017?select=races.csv

# Process
The whole process was executed in the term_project_code.sql file, in this description I am just grabbing some part of it.
## Operational layer
The first step was to create the operational layer by loading in needed data tables. I have used five tables from the date set.
### Creating tables
```
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
```
### Loading in data
```
LOAD DATA LOCAL INFILE '/Users/utassydv/Documents/workspaces/CEU/my_repos/data_engineering_1/Term DE1/formula_1_data/results.csv'
INTO TABLE results
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(result_id, race_id, driver_id, constructor_id, num, grid, pos, position_text, position_order, points);
```
## Analytics plan
My plan is to make it possible to analyse Formula 1 race results by Drivers, Constructors or by year. In order to make the analyzes convenient we need a table that contains all the results of all the drivers. The variable we need are the following: name of the driver, name of the constructor, starting grid position, finishing position, name of constructor, grand prix name, race year, race country. 
## Analytical layer
To make our previously defined goal possible we are creating a denormalized data structure in MySQL.
For this we need to join the loaded tables. 

### I used a stored procedure to proceed this step:
```
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

```

By calling this function, our analytical layer is completed.

## ETL pipeline
With this dataset it is straight forward that after a race is completed new data is added to some tables. In order to keep my denormalized table up to date, I need to refresh that one as well.

After a race a new observation is inserted into the races table, and every driver's result is added to the result table. In the following trigger I am handling this situation.
```
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
```
## DataMart
Our dataset is great for observing F1 race results filtering by drivers, constructors, or race locations. 

For that we can have DataMarts with views. I have created three of them 
- A view that shows all the Hungarian GPs
- A view that show all results by ferrari
- A view that shows all results of Sebastian Vettel


```
DROP VIEW IF EXISTS HungarianGPs;
CREATE VIEW `HungarianGPs` AS
SELECT * FROM f1_table WHERE f1_table.country = 'Hungary';
```