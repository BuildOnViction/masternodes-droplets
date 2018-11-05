#!/bin/bash

if [ ! -f /vagrant/node/tomo.ipc ]; then
    cd /vagrant && nohup bash ./add.sh<&- &>/vagrant/add.log &
fi
