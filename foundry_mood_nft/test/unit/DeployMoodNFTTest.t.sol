// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployMoodNFT} from "../../script/DeployMoodNFT.s.sol";

contract DeployMoodNFTTest is Test {
    DeployMoodNFT deployMoodNFT;

    function setUp() public {
        deployMoodNFT = new DeployMoodNFT();
    }

    function testSvgToImageURI() public view {
        string memory expectedUri =
            "data:image/svg+xml;base64,PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHdpZHRoPSc0MDAnIGhlaWdodD0nNDAwJz48cGF0aCBmaWxsPScjMzMzMycgZD0nTTUxMiA2NEMyNjQgNjQgNjQgMjY0IDY0IDUxMnMyMDAgNDQ4IDQ0OCA0NDhzNDQ4LTIwMCA0NDgtNDQ4cy0yMDAtNDQ4LTQ0OC00NDh6bTIwMCAxMDI0SDI3MmMtNzUgMC0xMzYtNjEtMTM2LTEzNlYyNzJjMC03NSA2MS0xMzYgMTM2LTEzNmg0NDBjNzUgMCAxMzYgNjEgMTM2IDEzNnY0NDBjMCA3NS02MSAxMzYtMTM2IDEzNnonLz48L3N2Zz4=";
        string memory svg =
            "<svg xmlns='http://www.w3.org/2000/svg' width='400' height='400'><path fill='#3333' d='M512 64C264 64 64 264 64 512s200 448 448 448s448-200 448-448s-200-448-448-448zm200 1024H272c-75 0-136-61-136-136V272c0-75 61-136 136-136h440c75 0 136 61 136 136v440c0 75-61 136-136 136z'/></svg>";
        string memory imageURI = deployMoodNFT.svgToImageURI(svg);
        assert(keccak256(abi.encodePacked(imageURI)) == keccak256(abi.encodePacked(expectedUri)));
    }
}
