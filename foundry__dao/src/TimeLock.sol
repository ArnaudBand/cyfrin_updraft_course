// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
    /**
     *
     * @notice miniDelay The minimum delay for the timelock
     * @notice proposers The list of proposers
     * @notice executors The list of executors
     */
    constructor(uint256 miniDelay, address[] memory proposers, address[] memory executors)
        TimelockController(miniDelay, proposers, executors, msg.sender)
    {}
}
