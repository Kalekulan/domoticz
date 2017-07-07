#!/bin/python3
from os import startfile
#import requests
from requests import get
import argparse
import logging as log


def send_cmd(process, idx, state):
    ""
    # http://domoticz.local:8080/json.htm?type=command&param=switchlight&idx=13&switchcmd=Off&level=0&passcode=
    url = ('http://domoticz.local:8080/json.htm?type=command&param=switchlight&idx='
           + idx
           + '&switchcmd='
           + state
           + '&level=0&passcode='
           )

    log.info("url = " + url)
    #r = requests.get(url)
    r = get(url, stream=True)
    #log.info("request response = " + r)
    r.json()
    startfile(process)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--process", dest="processPath",
                        help="write report to FILE", required=True)
    parser.add_argument("-v", "--verbose", help="increase output verbosity",
                        action="store_true")
    args = parser.parse_args()
    process = args.processPath

    if args.verbose:
        log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
        log.info("Verbose output.")
    else:
        log.basicConfig(format="%(levelname)s: %(message)s")

    send_cmd(process, '13', 'Off')


if __name__ == '__main__':
    main()
