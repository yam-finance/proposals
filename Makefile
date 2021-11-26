# Load `.env` file and export variables.
-include .env

# Test
test:; forge test -f --verbosity 3
