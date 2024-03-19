// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Staking} from "../src/Staking.sol";

contract DeployStaking is Script {
    Staking public staking;

    function setUp() public {
        vm.startBroadcast();
        staking = new Staking();
        vm.stopBroadcast();
    }

    function run() public {
        vm.broadcast();
    }
}
