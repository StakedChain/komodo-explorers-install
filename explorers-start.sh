#!/bin/bash

STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR
echo -e "$STEP_START[ Step 1 ]$STEP_END Starts all explorers in screen ..."

# Killing all previous instances ...
kill -9 $(pidof bitcore)

./listassetchains.py | while read i; do
    screen -d -m -S $i-explorer $CUR_DIR/$i-explorer-start.sh
done
