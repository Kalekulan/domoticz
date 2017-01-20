import os
import requests
import argparse
import logging as log

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--process", dest="processPath",
                    help="write report to FILE", required=True)
parser.add_argument("-v", "--verbose", help="increase output verbosity",
                    action="store_true")
args = parser.parse_args()
#if args.process:
	#print("process = " + args.process)
if args.verbose:
    log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
    log.info("Verbose output.")
else:
    log.basicConfig(format="%(levelname)s: %(message)s")

switchId='13' #Dimmer in right window
switchCmd='Off'

#http://domoticz.local:8080/json.htm?type=command&param=switchlight&idx=13&switchcmd=Off&level=0&passcode=
url = 'http://domoticz.local:8080/json.htm?type=command&param=switchlight&idx=' + switchId + '&switchcmd=' + switchCmd + '&level=0&passcode='
log.info("url = " + url)
#r = requests.get(url)
r = requests.get(url, stream=True)
#log.info("request response = " + r)
r.json()
#log.info("json = " + r.json())
#os.startfile('E:/Origin/Games/Battlefield 1/bf1.exe')
os.startfile(args.processPath)
#os.system("pause")
#os.open('E:/Origin/Games/Battlefield 1/bf1.exe')
#os.wait()