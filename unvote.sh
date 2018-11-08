#!/bin/bash

source /vagrant/.env

curl --header "Content-Type: application/json" \
  --request POST \
  "${TOMOMASTER}/api/candidates/unvote?key=${OWNER_PRIVATE_KEY}&coinbase=${COINBASE_ADDRESS}"
