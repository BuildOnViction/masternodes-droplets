#!/bin/bash

set +e

PROJECT_DIR="${HOME}/go/src/github.com/ethereum/go-ethereum"
DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"`

${PROJECT_DIR}/build/bin/tomo attach /vagrant/node/tomo.ipc --exec 'eth.blockNumber'
retval=$?

if [ $retval -ne 0 ]; then
    echo "Node stopped! Restart it!"
    cd /vagrant && nohup bash ./node.sh<&- &>/vagrant/node.${DATE_WITH_TIME}.log &
fi
