# MyToken ERC20 Bridge Project

This project showcases the implementation of a custom ERC20 token, `MyToken`, along with a robust bridging mechanism between Ethereum Sepolia (L1) and Poseidon (L2) networks. It enables seamless deployment, minting, and transfer of tokens across these networks using the Optimism Standard Bridge. By leveraging the OP Stack, the Standard Bridge facilitates secure and efficient movement of ERC20 tokens between Layer 1 (Ethereum/Sepolia) and Layer 2 (OP Stack chains like Poseidon), demonstrating the interoperability and scalability of modern blockchain solutions.

## Project Overview

The project consists of:

1. **MyToken Contract**: A basic ERC20 token with minting capabilities
2. **Deployment Scripts**: For deploying tokens on both L1 and L2 networks
3. **Bridge Scripts**: For transferring tokens between networks
4. **Utility Commands**: For checking balances and managing deployments

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- A wallet with funds on both Sepolia and Poseidon testnets
- RPC endpoints for both networks

### Windows Users

If you're on Windows, use [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install) to work with Foundry for the best development experience.

## Setup Instructions

1. **Clone the Repository**:

```bash
git clone https://github.com/hakimasyrofi/holdex-trial-senior-solidity-engineer
```

2. **Environment Setup**:

   - Rename `.env.example` to `.env`
   - Fill in your environment variables:
     - Wallet address and private key
     - RPC URLs for Sepolia and Poseidon
     - Etherscan API key for verification
     - Contract addresses (after deployment)

3. **Install Dependencies**:

   ```bash
   make install
   ```

4. **Build the Project**:
   ```bash
   make build
   ```

## Token Deployment

### Deploy on Sepolia (L1)

To deploy and verify the MyToken contract on Sepolia:

```bash
make deploy-verify-sepolia
```

This will:

- Deploy the MyToken contract
- Verify the contract on Etherscan
- Output the deployed contract address

### Deploy on Poseidon (L2)

After deploying on Sepolia, deploy the corresponding L2 token on Poseidon:

```bash
make deploy-poseidon
```

To verify the contract on Poseidon's Blockscout explorer:

```bash
make verify-poseidon
```

## Token Bridging

### Bridge L1 to L2 (Sepolia to Poseidon)

To send tokens from Sepolia to Poseidon:

1. Set the `BRIDGE_AMOUNT` in your `.env` file
2. Run:
   ```bash
   make bridge-l1-to-l2
   ```

### Bridge L2 to L1 (Poseidon to Sepolia)

To send tokens from Poseidon back to Sepolia:

```bash
make bridge-l2-to-l1
```

Note: L2 to L1 transfers require a challenge period (typically shorter on testnets) before the tokens are available on L1.

## Checking Balances

### Check L1 Balance (Sepolia)

```bash
make check-l1-balance
```

### Check L2 Balance (Poseidon)

```bash
make check-l2-balance
```

## Important Addresses

- Sepolia L1 Standard Bridge: `0x8f42bd64b98f35ec696b968e3ad073886464dec1`
- Poseidon L2 Standard Bridge: `0x4200000000000000000000000000000000000010`

## Resources

- Poseidon Testnet Faucet: [https://poseidon-testnet.hub.caldera.xyz](https://poseidon-testnet.hub.caldera.xyz)
- Sepolia Testnet Faucet: [https://alchemy.com/faucets/ethereum-sepolia](https://alchemy.com/faucets/ethereum-sepolia)
- Optimism Documentation: [https://docs.optimism.io](https://docs.optimism.io)

## Technical Details

- The project uses Foundry for development, testing, and deployment
- The MyToken contract is based on OpenZeppelin's ERC20 and Ownable implementations
- The Standard Bridge uses the `OptimismMintableERC20Factory` to create standardized L2 token representations that are compatible with the bridge system.
- Gas limits are set to 500,000 for L1 operations and 200,000 for L2 operations
