#!/bin/bash

#arg1 mode
#arg2 output path


#mountOutputPath="/var/systembackup/mountOutput.txt"
mode=${1,,}
echo $mode
size=${#mode}
echo $mode
rsyncOutputPath=$2
#rsyncOutputPath="/mnt/STORAGE_ee7e0/owncloud_backup"
drive="STORAGE_ee7e0"
date=$(date +\%Y\%m\%d)
DOMO_IP="domoticz.local"  # Domoticz IP
DOMO_PORT="8080"        # Domoticz port

#> $mountOutputPath
#mount | grep $drive > $mountOutputPath

echo Checking if $drive is mounted...
#if [ ! -s $mountOutputPath ]
if ! mount | grep $drive ; then
  echo $drive is not mounted. I will give it a shot...
  mount --all
  #mount | grep $drive > $mountOutputPath
  #if [ ! -s $mountOutputPath ]
  if ! mount | grep $drive ; then
    echo Still cant mount. Check connection... Bye.
    exit
  fi
fi
#echo Kill server
#echo $drive is mounted... Executing rsync command.

if [ $mode = 'full' ] || [ $mode = 'system' ]
then
  #service domoticz.sh stop
  /etc/init.d/domoticz.sh stop
  /etc/init.d/homebridge stop
  rsync -aAxXql --exclude-from=/var/rsync/rsyncExclusions.list /* $rsyncOutputPath/domoticz_rsync_temp
  #echo Putting it in a tar...
  tar -cvpzf $rsyncOutputPath/domoticz_backup_$date.tar.gz $rsyncOutputPath/domoticz_rsync_temp
  echo Start server again.
  /etc/init.d/domoticz.sh start
  /etc/init.d/homebridge start
fi

if [ $mode = 'full' ] || [ $mode = 'db' ]
then
  #  pid=$(pidof domoticz)
  pid=$(/bin/pidof domoticz)
  pidExitCode=$?
  echo Domoticz PID=$pid
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


    #!/bin/bash
        # I'M NOT THE AUTHOR OF THIS SCRIPT. ALL CODE BELONGS TO DOMOTICZ!
        #
        #

    # LOCAL/FTP/SCP/MAIL PARAMETERS
#    SERVER="192.168.0.10"   # IP of Network disk, used for ftp
 #   USERNAME="root"         # FTP username of Network disk used for ftp
  #  PASSWORD="root"         # FTP password of Network disk used for ftp
   # DESTDIR="/opt/backup"   # used for temorarily storage
#    DOMO_IP="192.168.0.90"  # Domoticz IP
#    DOMO_PORT="8080"        # Domoticz port
    ### END OF USER CONFIGURABLE PARAMETERS
#    TIMESTAMP=`/bin/date +%Y%m%d%H%M%S`
#    BACKUPFILE="domoticz_$TIMESTAMP.db" # backups will be named "domoticz_YYYYMMDDHHMMSS.db.gz"
#    BACKUPFILEGZ="$BACKUPFILE".gz
    ### Stop Domoticz, create backup, ZIP it and start Domoticz again
#    service domoticz.sh stop
#    /usr/bin/curl -s http://$DOMO_IP:$DOMO_PORT/backupdatabase.php > /tmp/$BACKUPFILE
#    service domoticz.sh start
#    gzip -9 /tmp/$BACKUPFILE
    ### Send to Network disk through FTP
#    curl -s --disable-epsv -v -T"/tmp/$BACKUPFILEGZ" -u"$USERNAME:$PASSWORD" "ftp://$SERVER/media/hdd/Domoticz_backup/"
    ### Remove temp backup file
 #   /bin/rm /tmp/$BACKUPFILEGZ
    ### Done!
