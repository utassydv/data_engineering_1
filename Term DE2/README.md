![Database diagram](/artifacts/pngs/logo_bestteam.png)

# Term Project - DE2

### Background - task interpretation ###
Our team consists of 3 very talented and motivated Business Analytics fresh grads who - against all odds - decided to make their company, called BestTeam Solutions ltd. We are not very well connected, and don’t have a lot of experience but we heard rumours that a huge navigation company, Baazee wishes to implement an audio module for bikers. It is not always obvious on motorcycles how to set up visual GPS devices, so Baazee decided to target bikers with a software which uses audio only when navigating. When we heard about the opportunity we immediately thought that this is our chance to shine.
We set out to convince Baazee to hire our small company so that we can help them in this new development work by introducing a new feature. We want to forecast the probabilities of a motorcycle injury given weather conditions, date, time and geographical information. We strongly believe that other than navigation, Baazee could easily collect such data, which could be exploited for predictive models. The predictions could then be used to notify users if conditions are such that there is higher probabilty that they will suffer an incident with a potential injury. Our model would not only help the company stand out from the competition, but could also help save lives. 
We decided to create a teaser in KNIME which we will show to the company representatives. This platform is great to visually demonstrate how easy it is to implement such a feature, and we can also show that we understand what we are doing. We will provide an end-to-end solution which entails data engineering, visualisation and analytics at the same time. However we also limited the scope of what we will show, as the more sophisticated work can only start once we are hired. This document is to introduce what we will include in the teaser.

### Data Sources ###

#### Motor Vehicle Collisions dataset ####
For this demo we used data that is publicly available, the Motor Vehicle Collision - Crashes dataset provided by the city of New York which has historic dates on motor injuries back to 2012. This dataset contains a huge amount of data with a crash event being an observation at a given time. It was collected between 07/01/2012 and 12/01/2020 however, we will only use data from the beginning of 2018 as we saw some issue with data quality for the dates before. We leveraged a variable that stated whether the crash resulted in an injury or not, geolocation data within New York and we also checked whether the months and the time had any significance when predicting. 

#### Climate Data API ####
In favour of having weather data from New York city from each and every day when we have logs of accidents, we decided to use the Climate Data API of the National Centers for Environmental Information (further referred to as NOAA). According to our research on the NOAA website, it turned out that we have to use the Global Historical Climate Network Daily (GHCND) to get the detailed weather data we need. For our team, the most valuable documentation was this pdf, in which the most important insights of this service and the interpretation of the returned values are described. 

### The operational layer ###

#### MongoDB ####

We decided to use MongoDB - Atlas in order to store our Motor Collisions data. MongoDB would be a great choice for this company as it allows access to data very rapidly and can also scale up very easily which would be crucially important if they want to expand. We created a Project called: Data_Engineering2_assignment and our first Cluster (with an M0 Cluster tier) called AssignmentDB. This cluster uses AWS as a cloud provider, with 512 MB storage which was more than enough to store our demo data. Before loading up our csv file, we first needed to configure our MongoDB security settings.  
We created one user, gave them a password and admin access, which was quite important later when we connected our instance to KNIME. We could have restricted our network access with an IP address criterion but didn’t do that for this demo. After configuration was done, we uploaded our tabular data as a collection with the use of MongoDB Compass which was stored as a document (in JSON format).
For some reason we ran into errors when experimenting with the MongDB Integration KNIME package, so we employed a workaround. We made use of the Python Integration for MongoDB, and connected to our Collection with a Python Source node. We iterated through the documents with the help of a cursor and saved down our data in tabular format so that it can be used easily for analytics (a screenshot of our MongoDB cluster is available in Appendix A). 

#### NOAA API and Postman ####

To collect data about the weather we used the API of the  National Oceanic and Atmospheric Administration (NOAA). Our goal was to get a single URL query whereby we can get all the desired values from the weather API for the given day. (We chose the following: daily average precipitation, daily snow depth, daily maximum temperature, daily minimum temperature, daily average wind speed). In order to interact with the API, we must request a token from this link with our email address.
Throughout the Data Engineering 2. Course we learned a very useful tool, that helps to make the experimenting phase with an API convenient, which is Postman. Using this software we are able to concatenate queries in an easy and straightforward way. 

After starting up Postman by clicking the “+New Collection” button we are able to instantiate a collection for our project. The next step is to create a new request. In our newly created collection, we do that (see Postman screenshot 1. & 2. in appendix).
One last step before creating a real query with postman is to set the token. By clicking a “Headers” tab we can do that by adding “token” as a key and our “TOKEN” (got in email) as a value. (see Postman screenshot 3. in appendix)
We are all set, now under the “Params” tab we have an obvious panel in which we can easily manipulate a URL with different parameters, it is possible to send the request with the “Send” button and we can immediately see the result as well. (see Postman screenshot 4. In appendix).

The output format of API:
![Database diagram](/Term DE2/artifacts/pngs/get_api_data.png)

As it is obvious from the picture above, the output format of the API is JSON. For each and every day we get the requested values from all the available weather stations in New York City. The JSON snippet above is one value from one station. We can identify the type of the value according to the “datatype” key. 

### ETL to Data Warehouse ###

#### Cleaning Initial data after import from MongoDB ####

After we imported the data, we carried out some initial data cleaning which is contained in the Clean Collisions db metanode. We removed columns that were not relevant for our research question. Then we removed all those rows which contained null values so that they don't affect the performance and accuracy of any machine learning algorithm which we carry out later. We then created dummy variables for the ‘No of Persons Injured’ column. If no of injured was greater than 0, that incident was given a value of 1 while those with 0 injuries were given a value of 0. This column will act as outcome variable for machine learning algorithms.

![Database diagram](/Term DE2/artifacts/pngs/clean_collisions.png)

#### Formatting Date column for API calls ####
The dates in our NYC Incidents dataset is in a mm/dd/yyyy format while the dates on the NOAA website are present in yyyy-mm-dd format. In order to be able to pull data via the Climate Data API, we had to convert our present dates into mm/dd/yyyy format. Hence, we first split the data column based on ‘/’ delimiter and renamed the new 3 columns to month,day and column. When we split the column, the new columns lost the 0 with single numeric numbers e.g ‘01 ‘became ‘1’ only. So we wrote a java code that adds a 0 next to single numeric numbers. We then concatenated the 3 columns into yyyy-mm-dd format.

![Database diagram](/Term DE2/artifacts/pngs/format_dates.png)

#### Usage of API in KNIME ####

![Database diagram](/Term DE2/artifacts/pngs/api_knime.png)

To get weather data from the API, we used the nodes above in KNIME. In the “String Manipulation” we format the query URL, in the “GroupBy” we avoid doing redundant queries by grouping by date and in the “GETRequest” node we communicate with the API (making sure to set the token in this configuration).
Clean API data 

![Database diagram](/Term DE2/artifacts/pngs/clean_weather.png)

There were two crucial points we managed to solve regarding the data from the API. At first for each day we had all the variables in a JSON format, therefore we needed to extract it into a tidy format. We used the “JSON Path” node of KNIME to solve this. We had to use this online tool, to experiment with the syntax. In the end, we ended up with the following line that we used in the “JSON PATH” node: $.['results'][?(@.datatype=='<DATA-TYPE>')]['value']. After that, we had to make an aggregation on values from the distinct weather stations. To solve this we used the R integration of KNIME with the following nodes: “Table to R”, “R to Table”. Our  API extracted data was in a listed format for each row. For the aggregation, we created a function that calculates the average, and is used with “mapply()” on our data table. The mapply function which takes lists as input went through each row list and executed the average function on it.  In the following nodes, we executed some basic cleaning on our data.


### Data Warehouse ###
In order to have a robust framework, we saved down our data warehouse to disk. This way we can work with the data from csv without executing our ETL pipeline, MongoDB and the NOAA API each time. Our data has 4 important dimensions: 

- Date&Time
- Locations
- Weather
- Whether an injury happened or not 

![Database diagram](/Term DE2/artifacts/pngs/dw_overview.png)

The below figure is a snapshot on the data which is in the data warehouse. For analytics we will further transform some of these variables (e.g. we will create dummy variables from categorical ones) so that they can be fed into the chosen Machine Learning models with Injury column being our target variable.

### Data Marts and analytics ###
#### Analytics #### 

![Database diagram](/Term DE2/artifacts/pngs/correlation.png)

** Correlation Matrix: ** We carried out Pearson's rank correlation on the data and came across some interesting results. Average Max Temperature and Average Min Temperature both are moderately positively correlated with getting injured with correlation of approx 0.28. It's a possibility that as temperatures rise, people prefer to stay indoors to avoid the heat. There is a low positive correlation of 0.17 between Mean Average Rain and getting injured. Mean Average Wind is moderately negatively correlated with getting injured with a correlation of -0.356. There seems to be no correlation between Mean Average Snow Depth and getting injured. 

** Machine Learning Prediction: ** In ‘Data Preparation' metanode, we create dummies for the categorical variables (we need n-1 dummies, so we drop one column in the next node). After that we do some data type transformation, remove NAs and normalise our quantitative variables. Using  the partitioning node, we split the data 70-30 for training and testing the model. We will test our models and results via Logistic Regression and Decision Tree models.

** Logistic Regression: ** We use the Logistic Regression Learner node to set the dummy reference category and target column and train it for 1000 epoch. We carry out the regression via Stochastic Average Gradient (SAG) method. This node feeds into the Logistic Regression Predictor column which predicts the response using the logistic regression model. This node appends a new column to the input table containing the prediction for each row. Scorer node compares the actual column and predicted column and predicts the accuracy of the model. As an example, our model shows people are 5% more likely to get injured in July.

![Database diagram](/Term DE2/artifacts/pngs/logit.png)

** Decision tree: ** We use the Decision Tree Learner node to predict the overall model. We use the Gini method as split criteria which is defined as 1 minus the sum of the squares of the class probabilities of a dataset. Next we set the pruning setting as ‘Minimum Description Length’ (MDL) to help generalize the model better. our learned decision tree model data is input into the Decision Tree predictor node which then predicts results on testing data. The scorer node lets us know the accuracy of our model.

![Database diagram](/Term DE2/artifacts/pngs/decision_tree.png)

** Results: ** The Decision Tree Model did a slightly better job at predicting the testing data with a 78.5% accuracy compared to a 78.2% accuracy from the logit. Both models have capacity for a lot of improvement in terms of accuracy but considering the limited scope of our task which is to showcase our model to Baazee, we are quite satisfied with our results.

### Visualizations ###

KNIME also has built in visualisation tools which are quite robust when it comes to integration and could be used for many different purposes. On the one hand we added some plots for data exploration and finding patterns in our data so that it can help fine-tune the employed models in the Analytics department. But the purpose of visualisation could also be to show important results for senior management so that they can appreciate the result of the work that has been done. We would highly advise Baazee to build out a framework to track user satisfaction (e.g. users can rate with 1-5 stars how good they found the received advice) so that we can also use that data to show important KPIs. In this teaser we just wanted to showcase a one examples, which is looking at average temperature changes in maximum temperatures in New York.

#### Average Max Temperature Histogram ####

As expected, we can observe seasonality in the highs and lows of the average max temperature in New York. The most warmest months in the past 3 years have been June, July, and August with the highest temperatures in July reaching up to 31 degree celsius on average. Apart from some erratic trends, the lowest max average temperature drops down to 9 degree celsius in the months of Feb and March for the past 3 years. We expect to observe the same trend in the future as well.

![Database diagram](/Term DE2/artifacts/pngs/avg_temp.png)

### Conclusion ###

Our goal was to create a teaser to convince a huge navigation company to hire us for their new project. We strongly believe that it would be highly advantageous for Baazee to include motorcycle injury predictions in its software given that they need something to stand out from the competition and beat other navigation companies while also helping their users stay healthy. We also think that our company proposed a very elegant and easily understandable solution by using the cutting-edge platform of KNIME which could be appealing for the Baazee board of decision makers. KNIME has a very active community, it’s open source and there are many integration packages out there so in our solution we would also propose to use that in production. With a few clicks, even senior employees from business, who might not be that familiar with coding software could do simple visualisations with a few clicks. On top of that we could also implement machine learning solutions as showcased in this documentation. We hope that both Baazee and us can tap into that potential and work together to make the world a better place for bikers.

### Appendix A - MongoDB instance ###

![Database diagram](/Term DE2/artifacts/pngs/avg_temp.png)


### Appendix B - Postman

![Database diagram](/Term DE2/artifacts/pngs/postman1.png)
![Database diagram](/Term DE2/artifacts/pngs/postman2.png)
![Database diagram](/Term DE2/artifacts/pngs/postman3.png)
![Database diagram](/Term DE2/artifacts/pngs/postman4.png)
