#!/bin/bash

#arg1 output path


mountOutputPath="/var/systembackup/mountOutput.txt"
rsyncOutputPath=$1
#rsyncOutputPath="/mnt/STORAGE_ee7e0/owncloud_backup"
drive="STORAGE_ee7e0"
date=$(date +\%Y\%m\%d)
DOMO_IP=""  # Domoticz IP 
DOMO_PORT=""        # Domoticz port 

> $mountOutputPath
mount | grep $drive > $mountOutputPath

#echo Checking if $drive is mounted...
if [ ! -s $mountOutputPath ]
then
        #echo $drive is not mounted. I'll give it a shot...
        mount --all
        mount | grep $drive > $mountOutputPath
        if [ ! -s $mountOutputPath ]
        then
                #echo Still can't mount. Check connection... Bye.
                exit
        fi
fi
#echo Kill server
service domoticz.sh stop
#echo $drive is mounted... Executing rsync command.
rsync -aAxXq --exclude-from=/var/rsync/rsyncExclusions.list /* $rsyncOutputPath/domoticz_rsync_temp
#echo Putting it in a tar...
tar -cvpzf $rsyncOutputPath/domoticz_backup_$date.tar.gz $rsyncOutputPath/domoticz_rsync_temp
#echo Taking a dump of mysql database.
/usr/bin/curl -s http://$DOMO_IP:$DOMO_PORT/backupdatabase.php > $rsyncOutputPath/domoticz_dbbackup_$date.sql
#echo Let me zip that for you...
gzip -f9 $rsyncOutputPath/domoticz_dbbackup_$date.sql # > /mnt/STORAGE_ee7e0/owncloud_backup/owncloud_dbbackup_$(date +\%Y\%m\%d).sql.gz
#echo Start server again.
service domoticz.sh start
#echo Script is done!


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