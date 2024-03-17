// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    // Fund the contract with 6 ETH (assuming ETH/USD rate is 2000)
//    uint256 amount = 0.1 ether;
    uint256 ethPrice = 2000;

    function setUp() public {
        fundMe = new FundMe();
    }
    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIsOwner() public {
        assertEq(fundMe.getOwner(), address(this));
    }

    function testGetVersion() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

}
