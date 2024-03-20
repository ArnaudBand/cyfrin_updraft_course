// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {FunWithStorage} from "../src/exampleStorage/FunWithStorage.sol";

contract DeployFunWithStorage is Script {
    FunWithStorage funWithStorage;
    function setUp() external {
        vm.startBroadcast();
        funWithStorage  = new FunWithStorage();
        vm.stopBroadcast();
    }

    function run() public {
        vm.broadcast();
    }
}
