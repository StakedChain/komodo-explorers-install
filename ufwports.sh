#!/bin/bash

CUR_DIR=$(pwd)

webport=3001

./listassetchains.py | while read i; do
   webport=$((webport+1))
   echo $webport > webport
   daemon_getinfo=$(~/staked/komodo/master/komodo-cli -ac_name=$i getinfo)
   daemon_name=$(echo $daemon_getinfo | jq .name)
   daemon_name=$(echo $daemon_name | tr -d '"')
   daemon_p2pport=$(echo $daemon_getinfo | jq .p2pport)
   echo "sudo ufw allow $daemon_p2pport/tcp comment '$daemon_name p2p port'"	
done

webport=$(cat ./webport)
rm webport
echo "sudo ufw allow from any to any port 3001:$webport proto tcp comment 'allow insight web ports'"
