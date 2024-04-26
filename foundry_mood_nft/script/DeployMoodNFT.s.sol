// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from 'forge-std/Script.sol';
import {MoodNFT} from '../src/MoodNFT.sol';
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployMoodNFT is Script {
    function run() external returns(MoodNFT) {
        string memory sadSVG = vm.readFile("./images/sad.svg");
        string memory happySVG = vm.readFile("./images/happy.svg");
        MoodNFT moodNFT = new MoodNFT(
            svgToImageURI(sadSVG),
            svgToImageURI(happySVG)
        );
        return moodNFT;
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseUrl = "data:image/svg+xml;base64,";
        string memory svgBase64Encode = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
        return string(abi.encodePacked(baseUrl, svgBase64Encode));
    }
}