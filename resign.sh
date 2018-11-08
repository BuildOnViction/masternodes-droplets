#!/bin/bash

source /vagrant/.env
PROJECT_DIR="${HOME}/go/src/github.com/ethereum/go-ethereum"

nodeBlockNumber=`${PROJECT_DIR}/build/bin/tomo attach /vagrant/node/tomo.ipc --exec 'eth.blockNumber'`
echo $nodeBlockNumber
 
if [ "${nodeBlockNumber}" -gt "${RESIGN_BLOCK_NUMBER}" ] && [ "${RESIGN_BLOCK_NUMBER}" != "0"]; then
    # store the whole response with the status at the and
    HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET ${TOMOMASTER}/api/candidates/${COINBASE_ADDRESS}/isCandidate)

    # extract the body
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')


    if [ "${HTTP_BODY}" == "1" ]; then
        curl --header "Content-Type: application/json" \
          --request POST \
          "${TOMOMASTER}/api/candidates/resign?key=${OWNER_PRIVATE_KEY}&coinbase=${COINBASE_ADDRESS}"
    fi
fi
