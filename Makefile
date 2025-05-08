-include .env

clean:; forge clean

build:; forge build

install:; \
	forge install foundry-rs/forge-std@v1.9.3 --no-commit --no-git && \
	forge install OpenZeppelin/openzeppelin-contracts@v5.3.0 --no-commit --no-git

deploy-sepolia:
	forge script script/DeployMyToken.s.sol:DeployMyToken --sig "deployMyToken()" --rpc-url $(SEPOLIA_RPC_URL) --private-key $(DEPLOYER_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(SEPOLIA_ETHERSCAN_API_KEY) -vvvv