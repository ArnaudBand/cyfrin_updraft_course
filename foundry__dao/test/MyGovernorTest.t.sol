// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {GovernToken} from "../src/GovernToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {Box} from "../src/Box.sol";

contract MyGovernorTest is Test {

  // contracts
  MyGovernor governor;
  GovernToken token;
  TimeLock timelock;
  Box box;

  address public USER = makeAddr("user");
  uint256 public constant INITIAL_SUPPLY = 100 ether;

  address[] public proposers;
  address[] public executors;

  uint256 public constant MINI_DELAY = 3600; // 1 hour - after proposal is approved

  function setUp() public {
    token = new GovernToken();
    token.mint(USER, INITIAL_SUPPLY);

    vm.startBroadcast(USER);
    token.delegate(USER);
    timelock = new TimeLock(MINI_DELAY, proposers, executors);
    governor = new MyGovernor(token, timelock);

    bytes32 proposerRole = timelock.PROPOSER_ROLE();
    bytes32 executorRole = timelock.EXECUTOR_ROLE();
    bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

    timelock.grantRole(proposerRole, address(governor));
    timelock.grantRole(executorRole, address(governor));
    timelock.revokeRole(adminRole, USER);
    vm.stopBroadcast();

    box = new Box();
    box.transferOwnership(address(timelock));
  }
}