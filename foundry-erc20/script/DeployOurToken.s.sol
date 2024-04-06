// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {OurToken} from "../src/OurToken.sol";

// Address of the ERC20: 0x71E6d438237762a6d3099D9cAcEb6c10582a4cd9

contract DeployOurToken is Script {
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    function run() external {
        vm.startBroadcast();
        new OurToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
    }
}
