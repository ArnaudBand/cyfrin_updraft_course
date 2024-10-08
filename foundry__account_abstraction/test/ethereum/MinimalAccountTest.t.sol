// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";
import {DeployMinimalAccount} from "script/DeployMinimalAccount.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp, PackedUserOperation} from "script/SendPackedUserOp.s.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";

contract MinimalAccountTest is Test {
    using MessageHashUtils for bytes32;

    HelperConfig helperConfig;
    MinimalAccount minimalAccount;
    ERC20Mock usdc;
    SendPackedUserOp sendPackedUserOp;

    uint256 public constant INITIAL_BALANCE = 1e18;
    address randomUser = makeAddr("randomUser");

    function setUp() public {
        DeployMinimalAccount deployMinimalAccount = new DeployMinimalAccount();
        (helperConfig, minimalAccount) = deployMinimalAccount.deployMinimalAccount();
        usdc = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
    }

    function testOwnerCanExecuteCommads() public {
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(
            address(usdc), 0, abi.encodeWithSignature("mint(address,uint256)", address(minimalAccount), INITIAL_BALANCE)
        );
        assertEq(usdc.balanceOf(address(minimalAccount)), INITIAL_BALANCE);
    }

    function testNotOwnerCannotExecuteCommads() public {
        vm.prank(randomUser);
        vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
        minimalAccount.execute(
            address(usdc), 0, abi.encodeWithSignature("mint(address,uint256)", address(minimalAccount), INITIAL_BALANCE)
        );
    }

    function testRecoverSignedOp() public {
        // Arrange
        bytes memory executeCallData = abi.encodeWithSelector(
            MinimalAccount.execute.selector,
            address(usdc), // address dest
            0, // uint256 value
            abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), INITIAL_BALANCE) // bytes calldata
        );
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generateSignedPackedUserOp(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );

        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);

        // Act
        address actualSigner = ECDSA.recover(userOperationHash.toEthSignedMessageHash(), packedUserOp.signature);

        // Assert
        assertEq(actualSigner, minimalAccount.owner());
    }

    function testValidationOfUserOps() public {
        // Arrange
        bytes memory executeCallData = abi.encodeWithSelector(
            MinimalAccount.execute.selector,
            address(usdc), // address dest
            0, // uint256 value
            abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), INITIAL_BALANCE) // bytes calldata
        );
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generateSignedPackedUserOp(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );

        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        uint256 missingAccountFunds = 10e18;

        // Act
        vm.prank(helperConfig.getConfig().entryPoint);
        uint256 validationData = minimalAccount.validateUserOp(packedUserOp, userOperationHash, missingAccountFunds);
        // Assert
        assertEq(validationData, 0);
    }

    function testValidationRevertWhenUserHasNotFunds() public {
        // Arrange
        bytes memory executeCallData = abi.encodeWithSelector(
            MinimalAccount.execute.selector,
            address(usdc), // address dest
            0, // uint256 value
            abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), INITIAL_BALANCE) // bytes calldata
        );
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generateSignedPackedUserOp(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );

        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        uint256 missingAccountFunds = 0;

        // Act
        vm.prank(helperConfig.getConfig().entryPoint);
        vm.expectRevert(MinimalAccount.MinimalAccount__FailedToPayPreFund.selector);
        minimalAccount.validateUserOp(packedUserOp, userOperationHash, missingAccountFunds);
    }

    function testGetEntryPoint() public {
        assertEq(minimalAccount.getEntryPoint(), helperConfig.getConfig().entryPoint);
    }

    function testEntryPointCanExecuteCommads() public {
        // Arrange
        bytes memory executeCallData = abi.encodeWithSelector(
            MinimalAccount.execute.selector,
            address(usdc), // address dest
            0, // uint256 value
            abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), INITIAL_BALANCE) // bytes calldata
        );
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generateSignedPackedUserOp(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );

        vm.deal(address(minimalAccount), 1e18);
        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = packedUserOp;

        vm.prank(randomUser);
        IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(ops, payable(randomUser));

        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), INITIAL_BALANCE);
    }
}
