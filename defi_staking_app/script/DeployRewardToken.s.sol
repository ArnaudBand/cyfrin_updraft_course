// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RewardToken} from "../src/RewardToken.sol";

contract DeployRewardToken is Script {
    RewardToken public rewardToken;

    function setUp() public {
        vm.startBroadcast();
        rewardToken = new RewardToken();
        vm.stopBroadcast();
    }

    function run() public {
        vm.broadcast();
    }
}
