#!/bin/bash

if [ ! -S /vagrant/node/tomo.ipc ]; then
    cd /vagrant && nohup bash ./node.sh<&- &>/vagrant/node.log &
fi
