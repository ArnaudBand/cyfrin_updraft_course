// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {DeployDogeNFT} from "../../script/DeployDogeNFT.s.sol";
import {DogeNFT} from "../../src/DogeNFT.sol";

contract DogeNFTTest is Test {
    DeployDogeNFT public deployer;
    DogeNFT public nft;

    address public USER = makeAddr("user");
    string public constant PUG =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() public {
        deployer = new DeployDogeNFT();
        nft = deployer.run();
    }

    function testNameIsCorrect() public view {
        string memory exceptedName = "DOGIE";
        string memory actualName = nft.name();
        assertEq(keccak256(abi.encodePacked(exceptedName)), keccak256(abi.encodePacked(actualName)));
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        nft.mintNFT(PUG);

        assertEq(nft.balanceOf(USER), 1);
        assertEq(keccak256(abi.encodePacked(nft.tokenURI(0))), keccak256(abi.encodePacked(PUG)));
    }
}
