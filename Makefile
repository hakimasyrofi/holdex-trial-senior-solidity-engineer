-include .env

clean:; forge clean

build:; forge build

install:; \
	forge install foundry-rs/forge-std@v1.9.3 --no-commit --no-git && \
	forge install OpenZeppelin/openzeppelin-contracts@v5.3.0 --no-commit --no-git

deploy-verify-sepolia:
	forge script script/DeployMyToken.s.sol:DeployMyToken --sig "deployMyToken()" --rpc-url $(SEPOLIA_RPC_URL) --private-key $(DEPLOYER_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(SEPOLIA_ETHERSCAN_API_KEY) -vvvv

deploy-poseidon:
	cast send 0x4200000000000000000000000000000000000012 "createOptimismMintableERC20(address,string,string)" $(SEPOLIA_CONTRACT_ADDRESS) "MyToken" "MTK" --private-key $(DEPLOYER_PRIVATE_KEY) --rpc-url $(POSEIDON_RPC_URL) --json | jq -r '.logs[0].topics[2]' | cast parse-bytes32-address

verify-poseidon:
	forge verify-contract --rpc-url $(POSEIDON_RPC_URL) $(POSEIDON_CONTRACT_ADDRESS) src/MyToken.sol:MyToken --verifier blockscout --verifier-url ${POSEIDON_BLOCKSCOUT_API_URL}/api/