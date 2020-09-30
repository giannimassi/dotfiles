#!/bin/bash
VM="unitec-mon.develer.net"
VMUSER=ubuntu
BANCHINO=172.25.100.2
DBCN="172.25.100.1"
DBIO1="172.25.2.1"
DBIO2="172.25.3.1"
DBIO3="172.25.4.1"

setup-tunnels() {    
    ## ssh tunnel for using banchino's GUI
    (ssh -L "3389:172.25.100.2:3389" "$VM" -l "$VMUSER" -N & )> /dev/null 2>&1
    BANCHINOTUNNELPID=$!

    ## DBCN tunnel
    (ssh -L 22101:$DBCN:22 "$VM" -l "$VMUSER" -N &) > /dev/null 2>&1
    DBCNTUNNELPID=$!

    ## DBIOs tunnels
    (ssh -L 22102:$DBIO1:22 "$VM" -l "$VMUSER" -N &) > /dev/null 2>&1
    DBIO1TUNNELPID=$!
    
    (ssh -L 22103:$DBIO2:22 "$VM" -l "$VMUSER" -N &) > /dev/null 2>&1
    DBIO2TUNNELPID=$!
    
    (ssh -L 22104:$DBIO3:22 "$VM" -l "$VMUSER" -N &) > /dev/null 2>&1
    DBIO3TUNNELPID=$!


    echo "Tunnels started:
    - port 3389: windows machine (rdp protocol)
    - port 22101: dbcn (ssh)
    - port 22102: dbio1 (ssh)
    - port 22103: dbio2 (ssh)
    - port 22104: dbio3 (ssh)

    "
    ## Wait for user input
    read -n 1 -s -r -p "Press any key to close all (ctrl-c leaves tunnels opened as background processes)... "
    echo ""
    
    ## Kill all tunnels
    kill $BANCHINOTUNNELPID > /dev/null 2>&1
    kill $DBCNTUNNELPID > /dev/null 2>&1
    kill $DBIO1TUNNELPID > /dev/null 2>&1
    kill $DBIO2TUNNELPID > /dev/null 2>&1
    kill $DBIO3TUNNELPID > /dev/null 2>&1
    echo "All tunnels closed"
}

setup-tunnels
