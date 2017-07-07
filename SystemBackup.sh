#!/bin/bash

#arg1 mode
#arg2 output path

mode = ${1,,}
echo $mode
size = ${#mode}
echo $mode
rsyncOutputPath = $2
drive = "STORAGE_ee7e0"
date = $(date +\%Y\%m\%d)
DOMO_IP = "domoticz.local"  # Domoticz IP
DOMO_PORT = "8080"        # Domoticz port

echo Checking if $drive is mounted...

if ! mount | grep $drive ; then
    echo $drive is not mounted. I will give it a shot...
    mount --all
    if ! mount | grep $drive ; then
        echo Still cant mount. Check connection... Bye.
        exit
    fi
fi
#echo Kill server
#echo $drive is mounted... Executing rsync command.

if [ $mode = 'full' ] || [ $mode = 'system' ]; then
    /etc/init.d/domoticz.sh stop
    /etc/init.d/homebridge stop
    rsync -aAxXql --exclude-from=/var/rsync/rsyncExclusions.list /* $rsyncOutputPath/domoticz_rsync_temp
    #echo Putting it in a tar...
    tar -cvpzf $rsyncOutputPath/domoticz_backup_$date.tar.gz $rsyncOutputPath/domoticz_rsync_temp
    echo Start server again.
    /etc/init.d/domoticz.sh start
    /etc/init.d/homebridge start
fi

if [ $mode = 'full' ] || [ $mode = 'db' ]; then
    #  pid=$(pidof domoticz)
    pid = $(/bin/pidof domoticz)
    pidExitCode = $?
    echo Domoticz PID = $pid
    if [ $pidExitCode == 0 ]; then
        echo Domoticz server is running. #pid exists
    else
        /etc/init.d/domoticz.sh start
        sleep 10
    fi
    echo Taking a dump of mysql database.
    /usr/bin/curl -s http://$DOMO_IP:$DOMO_PORT/backupdatabase.php > $rsyncOutputPath/domoticz_dbbackup_$date.sql
    echo Let me zip that for you...
    gzip -f9 $rsyncOutputPath/domoticz_dbbackup_$date.sql # > /mnt/STORAGE_ee7e0/owncloud_backup/owncloud_dbbackup_$(date +\%Y\%m\%d).sql.gz
fi
echo Script is done!
