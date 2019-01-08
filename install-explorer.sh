#!/bin/bash

#
# (c) Decker, 2018
#

# Additional info:
#
# If previous installation of all explorers failure in some reasons, plz remove *-explorer folders, *-explorer-start.sh files,
# and node_modules folder before you run ./install-explorer.sh again (!). It will prevent from uncomplete installation errors.
#

# https://askubuntu.com/questions/558280/changing-colour-of-text-and-background-of-terminal
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR
echo -e "$STEP_START[ Step 1 ]$STEP_END Installing dependencies"
sudo apt --yes install git
sudo apt --yes install build-essential pkg-config libc6-dev libevent-dev m4 g++-multilib autoconf libtool libncurses5-dev unzip git python zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler libqt4-dev libqrencode-dev libdb++-dev ntp ntpdate
sudo apt --yes install libcurl4-gnutls-dev
sudo apt --yes install curl screen


echo -e "$STEP_START[ Step 3 ]$STEP_END Installing NodeJS and Bitcore Node"

# install nodejs, n and other stuff
sudo apt --yes install libsodium-dev npm
sudo apt --yes install libzmq3-dev

# install nvm
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
# switch node setup with nvm
nvm install v4

npm install git+https://git@github.com/StakedChain/bitcore-node-komodo # npm install bitcore

# Start ports
rpcport=8232
zmqport=8332
webport=3001

# now we need to create assets configs for komodod and create explorers for each asset
ac_json=$(curl https://raw.githubusercontent.com/StakedChain/StakedNotary/master/assetchains.json 2>/dev/null)
echo $ac_json | jq .[] > /dev/null 2>&1
outcome=$(echo $?)
if [[ $outcome != 0 ]]; then
  echo -e "\033[1;31m ABORTING!!! assetchains.json is invalid, Help Human! \033[0m"
  exit
fi
echo $ac_json > assetchains.json

./listassetchains.py | while read i; do
   echo -e "$STEP_START[ Step 4.$i ]$STEP_END Preparing $i"
   rpcport=$((rpcport+1))
   zmqport=$((zmqport+1))
   webport=$((webport+1))
   #printf "%10s: rpc.$rpcport zmq.$zmqport web.$webport\n" $i
   mkdir -p $HOME/.komodo/$i
   touch $HOME/.komodo/$i/$i.conf
cat <<EOF > $HOME/.komodo/$i/$i.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:$zmqport
zmqpubhashblock=tcp://127.0.0.1:$zmqport
rpcallowip=127.0.0.1
rpcport=$rpcport
rpcuser=bitcoin
rpcpassword=local321
uacomment=bitcore
showmetrics=0

EOF

$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node create $i-explorer
cd $i-explorer
$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node install git+https://git@github.com/StakedChain/insight-api-komodo git+https://git@github.com/StakedChain/insight-ui-komodo
cd $CUR_DIR

cat << EOF > $CUR_DIR/$i-explorer/bitcore-node.json
{
  "network": "mainnet",
  "port": $webport,
  "services": [
    "bitcoind",
    "insight-api-komodo",
    "insight-ui-komodo",
    "web"
  ],
  "servicesConfig": {
    "bitcoind": {
      "connect": [
        {
          "rpchost": "127.0.0.1",
          "rpcport": $rpcport,
          "rpcuser": "bitcoin",
          "rpcpassword": "local321",
          "zmqpubrawtx": "tcp://127.0.0.1:$zmqport"
        }
      ]
    },
  "insight-api-komodo": {
    "rateLimiterOptions": {
      "whitelist": ["::ffff:127.0.0.1","127.0.0.1"],
      "whitelistLimit": 500000, 
      "whitelistInterval": 3600000 
    }
  }
  }
}

EOF

# creating launch script for explorer
cat << EOF > $CUR_DIR/$i-explorer-start.sh
#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
cd $i-explorer
nvm use v4; ./node_modules/bitcore-node-komodo/bin/bitcore-node start
EOF
chmod +x $i-explorer-start.sh

done
