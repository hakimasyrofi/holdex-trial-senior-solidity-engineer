// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MyToken
 * @dev Implementation of a basic ERC20 token with minting capabilities.
 */
contract MyToken is ERC20, Ownable {
    /**
     * @notice Initializes the token contract with name "MyToken" and symbol "MTK"
     * @dev Sets the deployer address as the initial owner of the contract
     */
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {}

    /**
     * @notice Mints new tokens and assigns them to the specified address
     * @dev Only callable by the contract owner
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint (in the smallest unit of the token)
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
