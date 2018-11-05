#!/bin/bash

source .env
touch .pwd

PROJECT_DIR="${HOME}/go/src/github.com/ethereum/go-ethereum"

if [ ! -d ./node/tomo/chaindata ]
then
  wallet=$(${PROJECT_DIR}/build/bin/tomo account import --password .pwd --datadir ./node <(echo ${COINBASE_PRIVATE_KEY}) | awk -v FS="({|})" '{print $2}')
  ${PROJECT_DIR}/build/bin/tomo --datadir ./node init ./genesis/genesis.json
else
  wallet=$(${PROJECT_DIR}/build/bin/tomo account list --datadir ./node | head -n 1 | awk -v FS="({|})" '{print $2}')
fi

VERBOSITY=3
GASPRICE="1"

echo Starting the node ...
${PROJECT_DIR}/build/bin/tomo --bootnodes "enode://7d8ffe6d28f738d8b7c32f11fb6daa6204abae990a842025b0a969aabdda702aca95a821746332c2e618a92736538761b1660aa9defb099bc46b16db28992bc9@${MAIN_IP}:30301" \
	--syncmode 'full' \
    --maxpeer 200 \
	--datadir ./node --networkid 89 --port 30306 --rpc --rpccorsdomain "*" \
	--rpcaddr 0.0.0.0 --rpcport 8548 --rpcvhosts "*" --unlock "${wallet}" --password .pwd \
	--mine --gasprice "${GASPRICE}" --targetgaslimit "420000000" --verbosity ${VERBOSITY} \
	--ethstats "${NODE_NAME}:test&test@${MAIN_IP}:3002"

