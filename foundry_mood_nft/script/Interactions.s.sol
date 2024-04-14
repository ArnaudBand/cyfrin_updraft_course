// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {DogeNFT} from "../src/DogeNFT.sol";

contract MintDogeNFT is Script {

        string public constant PUG =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("DogeNFT", block.chainid);
        mintNFtOncontract(mostRecentDeployed);
    }

    function mintNFtOncontract(address contractAddress) public {
        vm.startBroadcast();
        DogeNFT(contractAddress).mintNFT(PUG);
        vm.stopBroadcast();
    }
}