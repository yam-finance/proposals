#!/bin/bash
set -e

oops() {
    echo "$0:" "$@" >&2
    exit 1
}

export ETH_RPC_URL="https://fee7372b6e224441b747bf1fde15b2bd.eth.rpc.rivet.cloud"
export SOLC_FLAGS="--optimize --optimize-runs 50000"

dapp build

block=$(seth block latest)

export DAPP_TEST_TIMESTAMP=$(seth --field timestamp <<< "$block")
export DAPP_TEST_NUMBER=$(seth --field number <<< "$block")
export DAPP_TEST_ORIGIN="0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f"
export DAPP_TEST_ADDRESS="0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f"
export DAPP_TEST_CHAINED=99
printf 'Running test for address %s\n' "$DAPP_TEST_ADDRESS"
LANG=C.UTF-8 dapp test --rpc-url "https://eth-mainnet.alchemyapi.io/v2/kz2ThUAbvLkX8ZB0_eaMfnR80ZOkBTFU" -vv