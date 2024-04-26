// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from '../lib/forge-std/src/Script.sol';
import {MoodNFT} from '../src//MoodNFT.sol';
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployMoodNFT is Script {
    function run() external returns(MoodNFT) {
        
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        return string(abi.encodePacked('data:image/svg+xml;base64,', Base64.encode(bytes(svg))));
    }
}