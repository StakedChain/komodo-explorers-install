#!/bin/bash

CUR_DIR=$(pwd)

rpcport=8232
zmqport=8332
webport=3001

declare -a kmd_coins=(CFEKX CFEKY) # TODO use assetchains.json.

echo "sudo ufw allow 7770/tcp comment 'KMD p2p port'"

for i in "${kmd_coins[@]}"
do
   rpcport=$((rpcport+1))
   zmqport=$((zmqport+1))
   webport=$((webport+1))
   daemon_getinfo=$(komodo/src/komodo-cli -ac_name=$i getinfo)
   daemon_name=$(echo $daemon_getinfo | jq .name)
   daemon_name=$(echo $daemon_name | tr -d '"')
   daemon_rpcport=$(echo $daemon_getinfo | jq .rpcport)
   daemon_p2pport=$(echo $daemon_getinfo | jq .p2pport)
   daemon_magic=$(echo $daemon_getinfo | jq .magic)
   daemon_magic_hex=$(printf '%016x' $daemon_magic)
   echo "sudo ufw allow $daemon_p2pport/tcp comment '$daemon_name p2p port'"	
done

echo "# sudo ufw allow from any to any port 3001:$webport proto tcp comment 'allow insight web ports'"
