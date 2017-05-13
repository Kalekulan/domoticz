#!/usr/bin/env python3

import argparse
from subprocess import Popen, PIPE
from time import sleep

def ParseArguments():
    ""
    #python WifiBTPing.py -d 192.168.10.113 -n "Lukas iPhone 6" -ip 192.168.10.115 -m D8:BB:2C.AD:2C:B7 -i 40
    parser = argparse.ArgumentParser()
    parser._action_groups.pop()
    required = parser.add_argument_group('required arguments')
    optional = parser.add_argument_group('optional arguments')

    required.add_argument('--dIP', '-d',
                        action="store",
                        required=True,
                        help='Long and short together')
    required.add_argument('--name', '-n',
                        action="store",
                        required=True,
                        help='Long and short together')
    required.add_argument('--idx', '-i',
                        action="store",
                        required=True,
                        type=int,
                        help='Long and short together')
    optional.add_argument('--ip', '-ip',
                        action="store",
                        required=False,
                        help='Long and short together')
    optional.add_argument('--mac', '-m',
                        action="store",
                        required=False,
                        help='Long and short together')

    optional.add_argument('--interval', '-in',
                        action="store",
                        required=False,
                        default=60,
                        type=int,
                        help='Long and short together')
    optional.add_argument('--verbose', '-v',
                        action='store_true',
                        required=False,
                        help='increase output verbosity')
    return parser.parse_args()

#print(args.dIP)

class Pinger(object):
    "test"
    def __init__(self, dIP, deviceName, ipadr, idx, btMacAdr, interval):
        self.dIP = dIP
        self.deviceName = deviceName
        self.ipadr = ipadr
        self.idx = idx
        self.btMacAdr = btMacAdr
        self.interval = interval



args = ParseArguments()

pinger = Pinger( args.dIP, \
        args.name, \
        args.ip, \
        args.idx, \
        args.mac, \
        args.interval
)

def WiFiPing():
    cmd="fping -c1 -b 32 -t1000 " + str(pinger.ipadr) + " 2>/dev/null 1>/dev/null"
    print("Pinging ip adress " + str(pinger.ipadr))
    #subprocess.run("fping", "-c1", "-b", "32", "-t1000", pinger.ipadr, "/dev/null")
    fping = Popen(["fping", "-c1", "-b", "32", "-t1000", pinger.ipadr], stdin=PIPE, stdout=PIPE, stderr=PIPE, bufsize=-1)
    #fping = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    output, error = fping.communicate()
    sleep(1)
    print("With return code " + str(fping.returncode))
    return fping.returncode

def BTPing():
    print("Pinging bluetooth mac adress " + str(pinger.btMacAdr))
    l2ping = Popen(["l2ping", "-c1", "-s32", "-t1", pinger.btMacAdr, "/dev/null"], stdin=PIPE, stdout=PIPE, stderr=PIPE, bufsize=-1)
    output, error = l2ping.communicate()
    print("With return code " + str(l2ping.returncode))
    #subprocess.run("l2ping", "-c1", "-s32", "-t1", pinger.btMacAdr, "/dev/null")
    return l2ping.returncode

def CheckDomoticz():
    print("Checking Domoticz")
    cmd="curl -s http://" + str(pinger.dIP) + "/json.htm?type=devices&rid=" + pinger.idx
    #subprocess.run("curl", "-s", "http://" + pinger.dIP +"/json.htm?type=devices&rid=" + pinger.idx)#, "|", "grep", "'"Data" :'"", "|", "awk", "'{ print $3 }'", "|", "sed", "'s/[!@#\$%",^&*()]//g'")
    chkcurl = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE, bufsize=-1)
    output, error = chkcurl.communicate()
    print("With return code " + str(chkcurl.returncode))
    #std_out, std_err = pipes.communicate()
    return chkcurl.returncode

def UpdateDomoticz(state):
    print("Updating Domoticz")
    cmd="curl -s http://" + pinger.dIP + "/json.htm?type=command&param=switchlight&idx=" + pinger.idx + "&switchcmd=" + state + "2>/dev/null"
    updcurl = subprocess.Popen(["curl", "-s", "http://" + parser.dIP + "/json.htm?type=command&param=switchlight&idx=" + pinger.idx + "&switchcmd=" + state, "2>/dev/null"], stdin=PIPE, stdout=PIPE, stderr=PIPE, bufsize=-1)
    output, error = updcurl.communicate()
    print("With return code " + str(updcurl.returncode))
    #std_out, std_err = pipes.communicate()
    return updcurl.returncode

while True:
    #if args.ip is not None: wifiResult = pinger.WiFiPing
    #if args.mac is not None: btResult = pinger.BTPing

    if args.ip is not None: wifiResult = WiFiPing()
    if args.mac is not None: btResult = BTPing()
    #chkResult = CheckDomoticz()
    updResult = UpdateDomoticz('On')
    #if wifiResult or
    #sleep(pinger.interval)
