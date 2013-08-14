demotrends
==========

Code required to setup the demo trends website (http://demotrends.qubole.com)

Set up 
 1) Create the database - Run './webapp/script/init-mysql.sh' from console
 2) Run the migrations:  Run 'rake db:migrate' from the console
 
Populate Data in db 
1) Using Sample Data: Run 'rake db:seed' from the console. These will insert one row in each of the tables. 
2) Using SQL Dump: You can also use SQL dump file to populate your DB. This file has data from processed data from 30th June 2013 - 13th August 2013.
                   Run 'sudo mysql trend < webapp/db/sqldump/mysqldump_13AUG13.sql' from the console

Start the webapp
 1) Run './webapp/script/restart_server.sh' from console


If you face issue with permission denied in tmp/cache
 1) create a directory cache in tmp 
 