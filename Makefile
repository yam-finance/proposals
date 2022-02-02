# Load `.env` file and export variables.
-include .env

# Test
dapp-test:
	dapp test --rpc-url https://eth-mainnet.alchemyapi.io/v2/kz2ThUAbvLkX8ZB0_eaMfnR80ZOkBTFU -v --verbosity 3
forge-test:
	forge test -f https://eth-mainnet.alchemyapi.io/v2/kz2ThUAbvLkX8ZB0_eaMfnR80ZOkBTFU
