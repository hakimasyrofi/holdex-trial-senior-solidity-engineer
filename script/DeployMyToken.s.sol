// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

/**
 * @title MyToken Deployment Script
 * @notice This script handles the deployment of the MyToken contract
 * @dev Uses Foundry's Script utilities for deployment
 */
contract DeployMyToken is Script {
    /**
     * @notice Deploys a new instance of the MyToken contract
     * @return MyToken The deployed token contract instance
     */
    function deployMyToken() external returns (MyToken) {
        vm.startBroadcast();
        MyToken myToken = new MyToken();
        vm.stopBroadcast();
        return myToken;
    }
}
