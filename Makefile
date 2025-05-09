# MyToken Project Makefile
# This Makefile contains commands for building, deploying, and managing
# the MyToken ERC20 token on Sepolia testnet (L1) and Poseidon testnet (L2).

# Import environment variables from .env file
-include .env

# ============ DEVELOPMENT COMMANDS ============

# Clean build artifacts
clean:; forge clean

# Build the project using Forge
build:; forge build

# Install project dependencies
install:; \
	forge install foundry-rs/forge-std@v1.9.3 --no-commit --no-git && \
	forge install OpenZeppelin/openzeppelin-contracts@v5.3.0 --no-commit --no-git

# ============ DEPLOYMENT COMMANDS ============

# Deploy and verify MyToken contract on Sepolia (L1)
deploy-verify-sepolia:
	@echo "Deploying and verifying MyToken on Sepolia..."
	forge script script/DeployMyToken.s.sol:DeployMyToken --sig "deployMyToken()" --rpc-url $(SEPOLIA_RPC_URL) --private-key $(WALLET_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(SEPOLIA_ETHERSCAN_API_KEY) -vvvv

# Deploy MyToken on Poseidon (L2) using the StandardBridge contract
deploy-poseidon:
	@echo "Deploying MyToken on Poseidon..."
	cast send 0x4200000000000000000000000000000000000012 "createOptimismMintableERC20(address,string,string)" $(SEPOLIA_CONTRACT_ADDRESS) "MyToken" "MTK" --private-key $(WALLET_PRIVATE_KEY) --rpc-url $(POSEIDON_RPC_URL) --json | jq -r '.logs[0].topics[2]' | cast parse-bytes32-address

# Verify the contract on Poseidon using Blockscout Explorer
verify-poseidon:
	@echo "Verifying MyToken on Poseidon..."
	forge verify-contract --rpc-url $(POSEIDON_RPC_URL) $(POSEIDON_CONTRACT_ADDRESS) src/MyToken.sol:MyToken --verifier blockscout --verifier-url ${POSEIDON_BLOCKSCOUT_API_URL}/api/

# ============ BRIDGE COMMANDS ============

# Bridge tokens from Sepolia (L1) to Poseidon (L2)
bridge-l1-to-l2:
	@echo "Bridging tokens from Sepolia (L1) to Poseidon (L2)..."
	forge script script/BridgeERC20.s.sol:BridgeERC20 --sig "bridgeL1ToL2(address,address,uint256)" $(SEPOLIA_CONTRACT_ADDRESS) $(POSEIDON_CONTRACT_ADDRESS) $(BRIDGE_AMOUNT) --rpc-url $(SEPOLIA_RPC_URL) --private-key $(WALLET_PRIVATE_KEY) --broadcast -vvv

# Bridge tokens from Poseidon (L2) back to Sepolia (L1)
bridge-l2-to-l1:
	@echo "Bridging tokens from Poseidon (L2) to Sepolia (L1)..."
	forge script script/BridgeERC20.s.sol:BridgeERC20 --sig "bridgeL2ToL1(address,address,uint256)" $(POSEIDON_CONTRACT_ADDRESS) $(SEPOLIA_CONTRACT_ADDRESS) $(BRIDGE_AMOUNT) --rpc-url $(POSEIDON_RPC_URL) --private-key $(WALLET_PRIVATE_KEY) --broadcast -vvv

# ============ BALANCE CHECK COMMANDS ============

# Check token balance on Sepolia (L1)
check-l1-balance:
	@echo "Checking token balance on Sepolia (L1)..."
	cast call $(SEPOLIA_CONTRACT_ADDRESS) "balanceOf(address)(uint256)" $(WALLET_ADDRESS) --rpc-url $(SEPOLIA_RPC_URL)

# Check token balance on Poseidon (L2)
check-l2-balance:
	@echo "Checking token balance on Poseidon (L2)..."
	cast call $(POSEIDON_CONTRACT_ADDRESS) "balanceOf(address)(uint256)" $(WALLET_ADDRESS) --rpc-url $(POSEIDON_RPC_URL)