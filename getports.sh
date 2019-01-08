#!/bin/bash

CUR_DIR=$(pwd)

echo '
| Coin  | RPC port | ZMQ port | Web port | P2P port | Magic (hex) | Magic (dec) 
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |------------- |
| KMD | 8232 | 8332 | 3001 | **7770** | 0x8de4eef9 |  2380590841|'

rpcport=8232
zmqport=8332
webport=3001

./listassetchains.py | while read i; do
   rpcport=$((rpcport+1))
   zmqport=$((zmqport+1))
   webport=$((webport+1))
   daemon_getinfo=$(~/staked/komodo/master/komodo-cli -ac_name=$i getinfo)
   daemon_name=$(echo $daemon_getinfo | jq .name)
   daemon_name=$(echo $daemon_name | tr -d '"')
   daemon_rpcport=$(echo $daemon_getinfo | jq .rpcport)
   daemon_p2pport=$(echo $daemon_getinfo | jq .p2pport)
   daemon_magic=$(echo $daemon_getinfo | jq .magic)
   daemon_magic_hex=$(printf '%016x' $daemon_magic)
   echo "| $daemon_name | $daemon_rpcport ($rpcport) | $zmqport | $webport | $daemon_p2pport | 0x${daemon_magic_hex: -8} | $daemon_magic |"
done
