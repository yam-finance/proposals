# Load `.env` file and export variables.
-include .env

# Test
test:; forge test -f https://fee7372b6e224441b747bf1fde15b2bd.eth.rpc.rivet.cloud --sender 0xEC3281124d4c2FCA8A88e3076C1E7749CfEcb7F2 --tx-origin 0xEC3281124d4c2FCA8A88e3076C1E7749CfEcb7F2 --verbosity 3
