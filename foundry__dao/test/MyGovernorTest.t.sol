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
    uint256[] public values;
    bytes[] public calldatas;
    address[] public targets;

    uint256 public constant MINI_DELAY = 3600; // 1 hour - after proposal is approved
    uint256 public constant VOTING_DELAY = 1; // 1 block
    uint256 public constant QUORUM_PERCENTAGE = 4; // Need 4% of voters to pass
    uint256 public constant VOTING_PERIOD = 50400; // This is how long voting lasts

    address public constant VOTER = address(1);

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

    function testCanUpdateBoxWithoutGovernace() public {
        vm.expectRevert();
        box.store(42);
    }

    function testGovernanceUpdateProposalState() public {
        string memory description = "Update Box";
        bytes memory data = abi.encodeWithSignature("store(uint256)", 42);

        values.push(0);
        calldatas.push(data);
        targets.push(address(box));

        // 1. Propose to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        assertEq(uint256(governor.state(proposalId)), 0);
    }

    function testGovernanceCanBeActiveAfterVotingDelay() public {
        string memory description = "Update Box";
        bytes memory data = abi.encodeWithSignature("store(uint256)", 42);

        values.push(0);
        calldatas.push(data);
        targets.push(address(box));

        // 1. Propose to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        assertEq(uint256(governor.state(proposalId)), 1);
    }

    function testGovernanceCanVoteYesAndStateChangeToDefeated() public {
        string memory description = "Update Box";
        bytes memory data = abi.encodeWithSignature("store(uint256)", 42);

        values.push(0);
        calldatas.push(data);
        targets.push(address(box));

        // 1. Propose to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        // 2. Vote
        string memory reason = "I like 42";
        uint8 vote = 1;
        vm.prank(VOTER);
        governor.castVoteWithReason(proposalId, vote, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console.log("Proposal State: ", uint256(governor.state(proposalId)));
        assertEq(uint256(governor.state(proposalId)), 3);
    }
}
