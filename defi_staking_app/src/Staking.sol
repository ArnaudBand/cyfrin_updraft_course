// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    IER20 public s_stakingToken;

    constructor(address stakingToken) {
        s_stakingToken = IERC20(stakingToken);
    }
}
