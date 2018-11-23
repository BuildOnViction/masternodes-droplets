#!/bin/bash

PROJECT_DIR="${HOME}/go/src/github.com/ethereum/go-ethereum"
cd ${PROJECT_DIR} && git pull origin master && make all
