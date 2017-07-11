#!/bin/bash
# Allowed commands:
# Usage: ./rpicamera-com.sh $cmd
#


# Exit codes:
#   0 = failed
#   1 = supplied parameter is not known/accepted
#   2 = incorrect state

user= #ADD RPi USER HERE
host= #ADD HOST ADRESS HERE
auth_file= #FILL PATH TO FILE HERE
auth_user= $(sudo -u $user head -n 1 $auth_file)
auth_pw= $(sudo -u $user tail -1 $auth_file)

if [ "$0" != "" ]; then status=$(sudo -u $user curl --silent -u $auth_user:$auth_pw $host/"status_mjpeg.php" 2>/dev/null); fi

case "$1" in
    startCam)
        [ "$status" == "halted" ] && cmd="cmd_pipe.php?cmd=ru%200"
    ;;
    stopCam)
        [ "$status" == "ready" ] && cmd="cmd_pipe.php?cmd=ru%200"
    ;;

    capPhoto)
        [ "$status" == "ready" ] && cmd= "cam_pic.php > rpicamera_$(date +\%Y\%m\%d-\%H\%M\%S).jpg"
    ;;

    startCapFilm)
        [ "$status" == "ready" ] && cmd="cmd_pipe.php?cmd=ca%201"
    ;;

    stopCapFilm)
        [ "$status" == "video" ] && cmd="cmd_pipe.php?cmd=ca%201"
    ;;
    reboot)
        cmd="cmd_func.php?cmd=reboot"
    ;;

    *)
        echo $"Usage: $0 {startCam|stopCam|capPhoto|startCapFilm|stopCapFilm|reboot}"
        exit 1
esac

if [ "$cmd" != "" ]; then
    return=$(sudo -u $user curl --silent -u $auth_user:$auth_pw $host/$cmd 2>/dev/null)
    echo Done.
else
    echo "Incorrect state. Command not executed."
    exit 2
fi
