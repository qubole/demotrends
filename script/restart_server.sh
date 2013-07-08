#!/bin/bash -x

#set -e

#ECHO_CMD=echo

d=`dirname $0`
cd ${d}/../
app_dir_=`pwd`

app_env_="production"

a=(`echo $app_dir_ | tr "/" "\n"`)
user_=${a[1]}

islocal=`hostname | grep localhost | wc -l`

if [ "$1x" == "x" ]; then
    if [ $islocal == 1 -o "${user_}x" == "qboldevx" ]; then
        echo "[WARNING] Environment argument missing. Assuming 'development' as it is running as 'qboldevx' or on localhost" >& 2
    	  app_env_="development"
    else
        echo "[ERROR] Environment argument missing. Valid values: staging, production and development" >& 2
        exit 1
    fi
else
    app_env_=$1
fi
pushd ${app_dir_}

tmpd=`${app_dir_}/../setup/get_yaml_var.py ${app_dir_}/../hive_scripts/qbol.yml ${app_env_} tmp_dir`

mkdir -p $tmpd
chown -R ${user_} $tmpd
chmod -R +t $tmpd
chmod -R a+w $tmpd

# shutdown delayed_job workers
${ECHO_CMD} su --session-command="./utils-bin/proc_shutdown.sh -g -e 'delayed_job'" $user_

# shut down hive server
${ECHO_CMD} su --session-command="./utils-bin/qhsadmin.sh stopg" $user_

${ECHO_CMD} /etc/init.d/hadoop-0.20-qboljtproxy stop
${ECHO_CMD} passenger stop -p 80

if [ "${app_env_}" != "development" ]; then
  ${ECHO_CMD} su --session-command "RAILS_ENV=${app_env_} rake assets:precompile" $user_
fi

${ECHO_CMD} passenger start -p 80 -d -e ${app_env_} --user ${user_}

# start tunneling server
tunnelserver_script="/usr/lib/hive_scripts/service/tunneling/tunnelserver"
tunnelserver_dir="/media/ephemeral0/logs/tunneling"
mkdir -p ${tunnelserver_dir}
chown -R ${user_} ${tunnelserver_dir}
chmod -R +t ${tunnelserver_dir}
chmod -R a+w ${tunnelserver_dir}
${ECHO_CMD} su --session-command="nohup ${tunnelserver_script} restart &" ${user_}

# start hive server
${ECHO_CMD} su --session-command="./utils-bin/qhsadmin.sh start" $user_

# start 2 generic workers
${ECHO_CMD} su --session-command "RAILS_ENV=${app_env_} ./script/delayed_job -n 2 start" $user_

${ECHO_CMD} /etc/init.d/hadoop-0.20-qboljtproxy start ${app_env_}
popd

# start periodic tasks
RAILS_ENV=${app_env_} rake start_periodic
