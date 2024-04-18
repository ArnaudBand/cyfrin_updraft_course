// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {DogeNFT} from "../src/DogeNFT.sol";

contract MintDogeNFT is Script {
    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function run() external {
        address mostRecentlyDeployedDogieNft = DevOpsTools.get_most_recent_deployment("DogeNFT", block.chainid);
        mintNftOnContract(mostRecentlyDeployedDogieNft);
    }

    function mintNftOnContract(address dogieNftAddress) public {
        vm.startBroadcast();
        DogeNFT(dogieNftAddress).mintNFT(PUG_URI);
        vm.stopBroadcast();
    }
}
