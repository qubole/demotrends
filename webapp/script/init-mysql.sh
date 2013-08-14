#!/bin/bash

d=`dirname $0`
cd ${d}/../
srcroot=`pwd`

set -e # exit/stop on errors

sudo service mysqld start

# if root user is supposed to have a password 
# mysql -u root -proot <<EOF
echo "Setting up mysql db for app .."

mysql -u root <<EOF
create database trend;
create user 'demouser'@'localhost' identified by 'demouser';
grant all on trend.* to  'demouser'@'localhost';
create user 'demouser'@'%' identified by 'demouser';
grant all on trend.* to  'demouser'@'%';
EOF

echo "Done"
