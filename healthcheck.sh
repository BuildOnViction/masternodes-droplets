#!/bin/bash

PROJECT_DIR="${HOME}/go/src/github.com/ethereum/go-ethereum"

if [ ! -S /vagrant/node/tomo.ipc ]; then
    if ! ${PROJECT_DIR}/build/bin/tomo attach /vagrant/node/tomo.ipc --exec 'eth.blockNumber'; then
        echo "Node stopped! Restart it!"
        cd /vagrant && nohup bash ./node.sh<&- &>/vagrant/node.log &
    fi
fi
