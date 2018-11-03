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

if [ ! -d ./nodes/sun/tomo/chaindata ]
then
  wallet1=$(${PROJECT_DIR}/build/bin/tomo account import --password .pwd --datadir ./nodes/sun <(echo ${PRIVATE_KEY_SUN}) | awk -v FS="({|})" '{print $2}')
  wallet2=$(${PROJECT_DIR}/build/bin/tomo account import --password .pwd --datadir ./nodes/moon <(echo ${PRIVATE_KEY_MOON}) | awk -v FS="({|})" '{print $2}')
  wallet3=$(${PROJECT_DIR}/build/bin/tomo account import --password .pwd --datadir ./nodes/earth <(echo ${PRIVATE_KEY_EARTH}) | awk -v FS="({|})" '{print $2}')
  ${PROJECT_DIR}/build/bin/tomo --datadir ./nodes/sun init ./genesis/genesis.json
  ${PROJECT_DIR}/build/bin/tomo --datadir ./nodes/moon init ./genesis/genesis.json
  ${PROJECT_DIR}/build/bin/tomo --datadir ./nodes/earth init ./genesis/genesis.json
else
  wallet1=$(${PROJECT_DIR}/build/bin/tomo account list --datadir ./nodes/sun | head -n 1 | awk -v FS="({|})" '{print $2}')
  wallet2=$(${PROJECT_DIR}/build/bin/tomo account list --datadir ./nodes/moon | head -n 1 | awk -v FS="({|})" '{print $2}')
  wallet3=$(${PROJECT_DIR}/build/bin/tomo account list --datadir ./nodes/earth | head -n 1 | awk -v FS="({|})" '{print $2}')
fi

VERBOSITY=3
GASPRICE="1"

echo Starting the bootnode ...
${PROJECT_DIR}/build/bin/bootnode -nodekey ./bootnode.key &
child_proc=$! 

echo Starting the nodes ...
${PROJECT_DIR}/build/bin/tomo --bootnodes "enode://7d8ffe6d28f738d8b7c32f11fb6daa6204abae990a842025b0a969aabdda702aca95a821746332c2e618a92736538761b1660aa9defb099bc46b16db28992bc9@127.0.0.1:30301" --syncmode "full" --datadir ./nodes/sun --networkid 89 --port 30303 --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8545 --rpcvhosts "*" --unlock "${wallet1}" --password ./.pwd --mine --gasprice "${GASPRICE}" --targetgaslimit "420000000" --verbosity ${VERBOSITY} --ethstats "sun:test&test@localhost:3002" &
child_proc="$child_proc $!"

${PROJECT_DIR}/build/bin/tomo --bootnodes "enode://7d8ffe6d28f738d8b7c32f11fb6daa6204abae990a842025b0a969aabdda702aca95a821746332c2e618a92736538761b1660aa9defb099bc46b16db28992bc9@127.0.0.1:30301" --syncmode "full" --datadir ./nodes/moon --networkid 89 --port 30304 --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8546 --rpcvhosts "*" --unlock "${wallet2}" --password ./.pwd --mine --gasprice "${GASPRICE}" --targetgaslimit "420000000" --verbosity ${VERBOSITY} --ethstats "moon:test&test@localhost:3002" &
child_proc="$child_proc $!"

${PROJECT_DIR}/build/bin/tomo --bootnodes "enode://7d8ffe6d28f738d8b7c32f11fb6daa6204abae990a842025b0a969aabdda702aca95a821746332c2e618a92736538761b1660aa9defb099bc46b16db28992bc9@127.0.0.1:30301" --syncmode "full" --datadir ./nodes/earth --networkid 89 --port 30305 --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8547 --rpcvhosts "*" --unlock "${wallet3}" --password ./.pwd --mine --gasprice "${GASPRICE}" --targetgaslimit "420000000" --verbosity ${VERBOSITY} --ethstats "earth:test&test@localhost:3002"
