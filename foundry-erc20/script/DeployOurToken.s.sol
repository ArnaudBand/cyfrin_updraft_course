// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {OurToken} from "../src/OurToken.sol";

contract DeployOurToken is Script {
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    function run() external {
        vm.startBroadcast();
        new OurToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
    }
}
