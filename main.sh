#!/bin/bash
_interupt() { 
    echo "Shutdown $child_proc"
    kill -TERM $child_proc
    exit
}

trap _interupt INT TERM

source .env
touch .pwd
export $(cat .env | xargs)

WORK_DIR=$PWD
PROJECT_DIR="${HOME}/go/src/github.com/ethereum/go-ethereum"
cd $WORK_DIR

if [ ! -d ./node/tomo/chaindata ]
then
  wallet=$(${PROJECT_DIR}/build/bin/tomo account import --password .pwd --datadir ./node <(echo ${PRIVATE_KEY_FULLNODE}) | awk -v FS="({|})" '{print $2}')
  ${PROJECT_DIR}/build/bin/tomo --datadir ./node init ./genesis/genesis.json
else
  wallet=$(${PROJECT_DIR}/build/bin/tomo account list --datadir ./node | head -n 1 | awk -v FS="({|})" '{print $2}')
fi

GASPRICE="2500"

echo Starting the bootnode ...
${PROJECT_DIR}/build/bin/bootnode -nodekey ./bootnode.key &
child_proc=$! 

echo Starting the nodes ...
${PROJECT_DIR}/build/bin/tomo \
    --bootnodes "enode://7d8ffe6d28f738d8b7c32f11fb6daa6204abae990a842025b0a969aabdda702aca95a821746332c2e618a92736538761b1660aa9defb099bc46b16db28992bc9@127.0.0.1:30301" \
    --syncmode "full" --datadir ./node --networkid ${NETWORK_ID} --port 30303 \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8545 \
    --ws --wsaddr 0.0.0.0 \
    --wsport 8546 --wsorigins "*" --maxpeers 25 \
    --rpcvhosts "*" \
    --unlock "${wallet}" \
    --password ./.pwd \
    --mine --gasprice "${GASPRICE}" \
    --targetgaslimit "420000000" \
    --verbosity ${VERBOSITY} \
    --ethstats "${NODE_NAME}:test&test@localhost:3002"
