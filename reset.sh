#!/bin/bash

PROJECT_DIR="${HOME}/go/src/github.com/ethereum/go-ethereum"
DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"`
cd ${PROJECT_DIR} && git fetch origin

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

echo Local $LOCAL Base $BASE Remote $REMOTE
if [ $LOCAL != $REMOTE ] && [ $LOCAL == $BASE ]; then
    echo "Stop node!"
    pkill -f "bin/tomo"
    git pull origin && make all
    echo "Restart it!"
    cd /vagrant && nohup bash ./node.sh<&- &>/vagrant/node.reset.${DATE_WITH_TIME}.log &
else
    echo "Nothing to do!!!"
fi
