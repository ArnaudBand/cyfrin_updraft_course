// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ZksyncMinimalAccount} from "src/zkSync/ZksyncMinimalAccount.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Transaction} from "foundry-era-contracts/contracts/libraries/MemoryTransactionHelper.sol";

contract ZkSyncMinimalAccountTest is Test {
    ZksyncMinimalAccount minimal;
    ERC20Mock usdc;

    uint256 constant USDC_TOTAL_SUPPLY = 1e18;
    bytes32 constant EMPTY_BYTES = bytes32(0);

    function setUp() public {
        // Deploy the contract
        minimal = new ZksyncMinimalAccount();
        // Deploy the ERC20 token
        usdc = new ERC20Mock();
    }

    function testZkOwnerCanExecuteCommands() public {
        Transaction memory transaction = _createUnsignedTransaction(
            minimal.owner(),
            113,
            address(usdc),
            0,
            abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimal), USDC_TOTAL_SUPPLY)
        );

        vm.prank(minimal.owner());
        minimal.executeTransaction(EMPTY_BYTES, EMPTY_BYTES, transaction);

        assertEq(usdc.balanceOf(address(minimal)), USDC_TOTAL_SUPPLY);
    }

    // INTERNAL FUNCTIONS
    function _createUnsignedTransaction(
        address from,
        uint8 transactionType,
        address to,
        uint256 value,
        bytes memory data
    ) internal view returns (Transaction memory) {
        uint256 nonce = vm.getNonce(address(minimal));
        bytes32[] memory factoryDeps = new bytes32[](0);
        return Transaction({
            txType: transactionType,
            from: uint256(uint160(from)),
            to: uint256(uint160(to)),
            gasLimit: 16777216,
            gasPerPubdataByteLimit: 16777216,
            maxFeePerGas: 16777216,
            maxPriorityFeePerGas: 16777216,
            paymaster: 0,
            nonce: nonce,
            value: value,
            reserved: [uint256(0), uint256(0), uint256(0), uint256(0)],
            data: data,
            signature: hex"",
            factoryDeps: factoryDeps,
            paymasterInput: hex"",
            reservedDynamic: hex""
        });
    }
}
