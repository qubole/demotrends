# DemoTrends (http://demotrends.qubole.com)

A Big Data app that displays the topics that are trending on Wikipedia.
There are two main parts:
1. Webapp in Ruby on Rails.
2. Data pipeline hosted in *Qubole Data Service*

## Quick Start
1. Register for a [Trial Plan] (www.qubole.com/try) in Qubole
2. [Obtain the API key] (http://www.qubole.com/qds-api-reference/authentication/)
3. Run the commands in the *commands* directory

## Webapp

Code required to setup the demo trends website (http://demotrends.qubole.com)

#### Set up 
1. Create the database - `./webapp/script/init-mysql.sh`
2. Run the migrations:  `rake db:migrate`
 
#### Populate Data in db 
1. Using Sample Data: `rake db:seed` These will insert one row in each of the tables. 
2. Using SQL Dump: You can also use SQL dump file to populate your DB. This file has data from processed data from 30th June 2013 - 13th August 2013.
                   `sudo mysql trend < webapp/db/sqldump/mysqldump_13AUG13.sql`

#### Start the webapp
1.  Run `./webapp/script/restart_server.sh`

## Data Pipeline
### Hive
Directory contains two UDFs required by the data pipeline:
1. collect_all - A JAR UDF
2. hive_trend_mapper - A Python UDF

### Scripts
Directory contains scripts that are run in a *Shell Command*.
1. pagecount_dump.py - A script to download ONE days *pagecounts* data from the Wikimedia website.

### Commands
Directory contains all the commands to process one day's worth of data.
The sequence of commands is important. The filenames start with a number specifying the sequence it should be executed in.
Run the scripts using [Qubole Python SDK] (https://github.com/qubole/qds-sdk-py)
