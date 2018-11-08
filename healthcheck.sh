#!/bin/bash

if [ ! -S /vagrant/node/tomo.ipc ]; then
    echo "Node stopped! Restart it!"
    cd /vagrant && nohup bash ./node.sh<&- &>/vagrant/node.log &
fi
