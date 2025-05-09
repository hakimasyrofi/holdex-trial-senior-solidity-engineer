// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title BridgeERC20
 * @dev A Foundry script to facilitate ERC20 token transfers between Ethereum L1 (Sepolia)
 *      and L2 (Poseidon) networks using the standard bridge contracts
 */
interface IStandardBridge {
    function bridgeERC20(
        address _l1Token,
        address _l2Token,
        uint256 _amount,
        uint32 _l2Gas,
        bytes calldata _data
    ) external;
}

contract BridgeERC20 is Script {
    // Standard Bridge addresses loaded from environment variables
    address public l1BridgeAddress;
    address public l2BridgeAddress;

    // Default gas limit for finalizing withdrawals on L1 network
    uint32 constant DEFAULT_L1_GAS = 500_000;
    // Default gas limit for operations on L2 network
    uint32 constant DEFAULT_L2_GAS = 200_000;

    // Load bridge addresses from environment variables in constructor
    constructor() {
        l1BridgeAddress = vm.envAddress("L1_BRIDGE_ADDRESS");
        l2BridgeAddress = vm.envAddress("L2_BRIDGE_ADDRESS");
    }

    /**
     * @notice Deposits and bridges ERC20 tokens from L1 (Sepolia) to L2 (Poseidon)
     * @param l1TokenAddress Address of the token contract on L1
     * @param l2TokenAddress Corresponding token address on L2
     * @param amount Amount of tokens to bridge to L2
     */
    function bridgeL1ToL2(
        address l1TokenAddress,
        address l2TokenAddress,
        uint256 amount
    ) public {
        vm.startBroadcast();
        // Approve the L1 bridge to spend tokens
        IERC20(l1TokenAddress).approve(l1BridgeAddress, amount);
        console.log("Approved L1 bridge to spend %s tokens", amount);

        // Deposit tokens to L2
        IStandardBridge(l1BridgeAddress).bridgeERC20(
            l1TokenAddress,
            l2TokenAddress,
            amount,
            DEFAULT_L2_GAS,
            ""
        );
        console.log("Bridged %s tokens from L1 to L2", amount);
        vm.stopBroadcast();
    }

    /**
     * @notice Initiates withdrawal of ERC20 tokens from L2 (Poseidon) to L1 (Sepolia)
     * @dev This starts the withdrawal process on L2, which will need to be finalized on L1 after challenge period
     * @param l2TokenAddress Address of the token contract on L2
     * @param l1TokenAddress Corresponding token address on L1
     * @param amount Amount of tokens to withdraw to L1
     */
    function bridgeL2ToL1(
        address l2TokenAddress,
        address l1TokenAddress,
        uint256 amount
    ) public {
        vm.startBroadcast();
        // Approve the L2 bridge to spend tokens (if needed)
        IERC20(l2TokenAddress).approve(l2BridgeAddress, amount);
        console.log("Approved L2 bridge to spend %s tokens", amount);

        // Initiate withdrawal from L2 to L1
        IStandardBridge(l2BridgeAddress).bridgeERC20(
            l2TokenAddress,
            l1TokenAddress,
            amount,
            DEFAULT_L1_GAS,
            ""
        );
        console.log("Initiated bridging of %s tokens from L2 to L1", amount);
        vm.stopBroadcast();
    }
}
