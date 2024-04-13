// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DogeNFT} from "../src/DogeNFT.sol";

contract DeployDogeNFT is Script {
    function run() external returns (DogeNFT) {
        vm.startBroadcast();
        DogeNFT nft = new DogeNFT();
        vm.stopBroadcast();
        return nft;
    }
}
