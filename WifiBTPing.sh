#!/bin/bash

# Set Parameters
Name='Lukas iPhone 6'
domoticzIP='192.168.10.113'
IDX='40'
IP='192.168.10.115'
btMAC='D8:BB:2C.AD:2C:B7'
interval='30' #seconds
attempt=0

function WiFiPing() {
    # First network ping attempt
    local success=""
    fping -c1 -b 32 -t1000 $IP 2>/dev/null 1>/dev/null
    if [ "$?" = 0 ] ; then
      device=$(echo "On")
      #technology="BluetoothPing() $attempt attempt"
      success=true
      sleep 1
    else
      success=false
      #technology=''
    fi
    echo "$success"
}

function BluetoothPing() {
    # First bluetooth ping attempt
    #if [[ $success != 'yes' ]];
    local success=""
    bt=$(l2ping -c1 -s32 -t1 "$btMAC" > /dev/null && echo "On" || echo "Off")
    if [[ $bt == 'On' ]]; then
        device=$(echo "On")
        #technology="BluetoothPing() $attempt attempt"
        success=true
    else
        success=false
    fi
    #fi
    echo "$success"
}

function UpdateDomoticz() {
    local device=$1
    # Check Online / Offline state of Domoticz device
    local domoticzstatus=$(curl -s "http://"$domoticzIP"/json.htm?type=devices&rid="$IDX"" | grep '"Data" :' | awk '{ print $3 }' | sed 's/[!@#\$%",^&*()]//g')
    # Compare ping result to Domoticz device status
    if [ "$device" = "$domoticzstatus" ] ; then
        #echo "Status in sync $technology"
        echo "Status in sync"
        else
        echo "Status out of sync, correcting..."
        if [ "$device" = On ] ; then
            echo "$Name" "Online"
            curl -s "http://"$domoticzIP"/json.htm?type=command&param=switchlight&idx="$IDX"&switchcmd=On" 2>/dev/null 1>/dev/null
        else
            echo "$Name" "Offline"
            curl -s "http://"$domoticzIP"/json.htm?type=command&param=switchlight&idx="$IDX"&switchcmd=Off" 2>/dev/null 1>/dev/null
        fi
    fi
    local exitCode=$?
    echo $exitCode
}


while [ 1 ]
do
    #result=$(myfunc)   # or result=`myfunc`
    ((attempt+=1))
    echo "WiFiPing() attempt $attempt"
    wifiStatus=$(WiFiPing)
    if [[ $wifiStatus != true ]]; then
        device=$(echo "Off")
        echo "BluetoothPing() attempt $attempt"
        btStatus=$(BluetoothPing)
        if [[ $btStatus != true ]]; then
            device=$(echo "Off")
        else
            device=$(echo "On")
            return=$(UpdateDomoticz $device)
        fi
    else
        return=$(UpdateDomoticz $device)
    fi


    # If the device is still offline, declare it for processing
    #if [[ $wifiStatus != true ]]; then

    sleep $interval
done
