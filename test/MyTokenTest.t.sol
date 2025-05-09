// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";
import {MyToken} from "../src/MyToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BridgeERC20} from "../script/BridgeERC20.s.sol";

contract MyTokenTest is Test {
    MyToken private myToken;
    MyToken private l2Token; // Mock L2 token for bridge testing
    BridgeERC20 private bridge;

    // Set up addresses for testing
    address private ADMIN;
    address private USER1 = makeAddr("user1");
    address private USER2 = makeAddr("user2");

    // Mock bridge addresses
    address private L1_BRIDGE = makeAddr("l1Bridge");
    address private L2_BRIDGE = makeAddr("l2Bridge");

    // Test amounts
    uint256 private constant INITIAL_MINT = 1_000_000 * 10 ** 18; // 1 million tokens
    uint256 private constant TRANSFER_AMOUNT = 50_000 * 10 ** 18; // 50,000 tokens
    uint256 private constant BRIDGE_AMOUNT = 25_000 * 10 ** 18; // 25,000 tokens

    function setUp() public {
        // Setup environment variables for bridge addresses
        vm.setEnv("L1_BRIDGE_ADDRESS", vm.toString(L1_BRIDGE));
        vm.setEnv("L2_BRIDGE_ADDRESS", vm.toString(L2_BRIDGE));

        // Deploy the MyToken contract (L1 token)
        vm.startBroadcast();
        myToken = new MyToken();
        vm.stopBroadcast();

        // Deploy a second MyToken contract to simulate L2 token
        vm.startBroadcast();
        l2Token = new MyToken();
        vm.stopBroadcast();

        // Get the admin address (owner of the token)
        ADMIN = myToken.owner();

        // Mint initial tokens to the ADMIN address on L1
        vm.prank(ADMIN);
        myToken.mint(ADMIN, INITIAL_MINT);

        // Mint initial tokens to the L2 Bridge (simulating tokens on L2)
        vm.prank(l2Token.owner());
        l2Token.mint(L2_BRIDGE, INITIAL_MINT / 2);

        // Create mock bridge contract
        bridge = new BridgeERC20();

        // Setup mocks for bridge contracts
        // Mock L1 bridge to handle token approvals and transfers
        vm.mockCall(
            L1_BRIDGE,
            abi.encodeWithSignature(
                "bridgeERC20(address,address,uint256,uint32,bytes)",
                address(myToken),
                address(l2Token),
                BRIDGE_AMOUNT,
                uint32(200_000),
                ""
            ),
            abi.encode()
        );

        // Mock L2 bridge to handle token approvals and transfers
        vm.mockCall(
            L2_BRIDGE,
            abi.encodeWithSignature(
                "bridgeERC20(address,address,uint256,uint32,bytes)",
                address(l2Token),
                address(myToken),
                BRIDGE_AMOUNT,
                uint32(500_000),
                ""
            ),
            abi.encode()
        );
    }

    function test00InitialValues() public view {
        // Test token name and symbol
        assertEq(myToken.name(), "MyToken");
        assertEq(myToken.symbol(), "MTK");

        // Test initial supply
        assertEq(myToken.totalSupply(), INITIAL_MINT);

        // Test admin balance
        assertEq(myToken.balanceOf(ADMIN), INITIAL_MINT);

        // Test ownership
        assertEq(myToken.owner(), ADMIN);
    }

    function test01MintingTokens() public {
        uint256 mintAmount = 100_000 * 10 ** 18; // 100,000 tokens
        uint256 initialSupply = myToken.totalSupply();

        // Only owner should be able to mint
        vm.prank(ADMIN);
        myToken.mint(USER1, mintAmount);

        // Test new balance of USER1
        assertEq(myToken.balanceOf(USER1), mintAmount);

        // Test total supply increased
        assertEq(myToken.totalSupply(), initialSupply + mintAmount);

        // Test minting by non-admin (should revert)
        vm.prank(USER1);
        vm.expectRevert();
        myToken.mint(USER1, mintAmount);
    }

    function test02TransferTokens() public {
        // Transfer tokens from ADMIN to USER1
        vm.prank(ADMIN);
        bool success = myToken.transfer(USER1, TRANSFER_AMOUNT);
        assertTrue(success);

        // Check balances after transfer
        assertEq(myToken.balanceOf(USER1), TRANSFER_AMOUNT);
        assertEq(myToken.balanceOf(ADMIN), INITIAL_MINT - TRANSFER_AMOUNT);

        // Transfer from USER1 to USER2
        vm.prank(USER1);
        success = myToken.transfer(USER2, TRANSFER_AMOUNT / 2);
        assertTrue(success);

        // Check balances after second transfer
        assertEq(myToken.balanceOf(USER1), TRANSFER_AMOUNT / 2);
        assertEq(myToken.balanceOf(USER2), TRANSFER_AMOUNT / 2);
    }

    function test03ApproveAndTransferFrom() public {
        uint256 approveAmount = TRANSFER_AMOUNT;

        // ADMIN approves USER1 to spend tokens
        vm.prank(ADMIN);
        bool success = myToken.approve(USER1, approveAmount);
        assertTrue(success);

        // Check allowance
        assertEq(myToken.allowance(ADMIN, USER1), approveAmount);

        // USER1 transfers tokens from ADMIN to USER2
        vm.prank(USER1);
        success = myToken.transferFrom(ADMIN, USER2, approveAmount / 2);
        assertTrue(success);

        // Check balances after transferFrom
        assertEq(myToken.balanceOf(ADMIN), INITIAL_MINT - (approveAmount / 2));
        assertEq(myToken.balanceOf(USER2), approveAmount / 2);

        // Check remaining allowance
        assertEq(myToken.allowance(ADMIN, USER1), approveAmount / 2);
    }

    function test04BurnTokens() public {
        uint256 burnAmount = TRANSFER_AMOUNT;

        // Transfer tokens to USER1 first
        vm.prank(ADMIN);
        myToken.transfer(USER1, burnAmount);

        // USER1 "burns" tokens by sending to address(0) - this should fail due to ERC20 safety checks
        vm.prank(USER1);
        vm.expectRevert();
        myToken.transfer(address(0), burnAmount);
    }

    function test05BridgeL1ToL2() public {
        // Prepare for bridging: ADMIN needs to approve the bridge contract
        vm.startPrank(ADMIN);

        // Mock the token approval
        myToken.approve(L1_BRIDGE, BRIDGE_AMOUNT);

        // Call the bridge function directly
        // We don't use expectCall here since we're doing the transfer ourselves

        // In a real scenario, the bridge would move tokens to itself
        // Here we simulate this by directly transferring tokens to the bridge
        myToken.transfer(L1_BRIDGE, BRIDGE_AMOUNT);

        vm.stopPrank();

        // Verify the tokens have moved to the L1 bridge
        assertEq(myToken.balanceOf(L1_BRIDGE), BRIDGE_AMOUNT);
        assertEq(myToken.balanceOf(ADMIN), INITIAL_MINT - BRIDGE_AMOUNT);
    }

    function test06BridgeL2ToL1() public {
        // Simulate a user having tokens on L2
        address L2_USER = makeAddr("l2User");

        // Mint some tokens to the L2 user
        vm.prank(l2Token.owner());
        l2Token.mint(L2_USER, BRIDGE_AMOUNT);

        // Prepare for bridging: L2 user needs to approve the bridge contract
        vm.startPrank(L2_USER);

        // Mock the token approval
        l2Token.approve(L2_BRIDGE, BRIDGE_AMOUNT);

        // In a real scenario, the bridge would move tokens to itself
        // Here we simulate this by directly transferring tokens to the bridge
        l2Token.transfer(L2_BRIDGE, BRIDGE_AMOUNT);

        vm.stopPrank();

        // Verify the tokens have moved to the L2 bridge
        assertEq(
            l2Token.balanceOf(L2_BRIDGE),
            INITIAL_MINT / 2 + BRIDGE_AMOUNT
        );
        assertEq(l2Token.balanceOf(L2_USER), 0);
    }
}
