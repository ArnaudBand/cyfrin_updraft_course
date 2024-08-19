// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";
import {DeployMinimalAccount} from "script/DeployMinimalAccount.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract MinimalAccountTest is Test {
  HelperConfig helperConfig;
  MinimalAccount minimalAccount;
  ERC20Mock usdc;
  uint256 public constant INITIAL_BALANCE = 1e18;
  address randomUser = makeAddr("randomUser");
  function setUp() public {
    DeployMinimalAccount deployMinimalAccount = new DeployMinimalAccount();
    (helperConfig, minimalAccount) = deployMinimalAccount.deployMinimalAccount();
    usdc = new ERC20Mock();
  }

  function testOwnerCanExecuteCommads() public {
    minimalAccount.execute(address(usdc), 0, abi.encodeWithSignature("mint(address,uint256)", address(this), INITIAL_BALANCE));
    assertEq(usdc.balanceOf(address(this)), INITIAL_BALANCE);
  }

  function testNotOwnerCannotExecuteCommads() public {
    vm.prank(randomUser);
    vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
    minimalAccount.execute(address(usdc), 0, abi.encodeWithSignature("mint(address,uint256)", address(minimalAccount), INITIAL_BALANCE));
  }
}