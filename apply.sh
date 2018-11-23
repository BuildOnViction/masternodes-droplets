#!/bin/bash

source /vagrant/.env
PROJECT_DIR="${HOME}/go/src/github.com/ethereum/go-ethereum"

chainBlockNumber=`${PROJECT_DIR}/build/bin/tomo attach "${RPC_URL}" --exec 'eth.blockNumber'`
nodeBlockNumber=`${PROJECT_DIR}/build/bin/tomo attach /vagrant/node/tomo.ipc --exec 'eth.blockNumber'`
echo $chainBlockNumber
echo $nodeBlockNumber
 
if [ "${chainBlockNumber}" == "${nodeBlockNumber}" ]; then
    curl --header "Content-Type: application/json" \
      --request POST \
      "${TOMOMASTER}/api/candidates/apply?key=${OWNER_PRIVATE_KEY}&coinbase=${COINBASE_ADDRESS}&name=${NODE_NAME}"
fi
