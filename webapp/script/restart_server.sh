#!/bin/bash -x

#set -e

#ECHO_CMD=echo
#ECHO_CMD=echo
ECHO_CMD="time"

d=`dirname $0`
cd ${d}/../
app_dir_=`pwd`

app_env_="production"

a=(`echo $app_dir_ | tr "/" "\n"`)
user_=${a[1]}

if [ "x${user_}" != "xec2-user" ]; then
  app_env_="development"
fi

pushd ${app_dir_}

sudo passenger stop -p 80

sudo passenger start -p 80 -d -e ${app_env_} --user ${user_}


