# DemoTrends (http://demotrends.qubole.com)

A Big Data app that displays the topics that are trending on Wikipedia.
There are two main parts:
1. Webapp in Ruby on Rails.
2. Data pipeline hosted in *Qubole Data Service*

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
