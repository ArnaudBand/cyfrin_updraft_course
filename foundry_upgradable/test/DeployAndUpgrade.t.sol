// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgrade is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    // BoxV1 public boxV1;
    address public proxy;

    address public OWNER = makeAddr("OWNER");

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployer.run();
    }

    function testDeployment() public view {
        uint256 expectedValue = 1;
        assertEq(expectedValue, BoxV1(proxy).version());
    }

    function testOwnership() public {
        BoxV1(address(proxy)).initialize(msg.sender);
        assertEq(msg.sender, BoxV1(proxy).owner());
    }

    function testProxyStartAsBoxV1() public {
        vm.expectRevert();
        BoxV2(proxy).store(42);
    }

    function testUpgrades() public {
        BoxV2 box2 = new BoxV2();
        upgrader.upgradeBox(proxy, address(box2));

        uint256 expectedValue = 2;
        assertEq(expectedValue, BoxV2(proxy).version());

        BoxV2(proxy).store(42);
        assertEq(42, BoxV2(proxy).getNumber());
    }

    function testUnAuthorizedUpgrade() public {
        BoxV2 box2 = new BoxV2();

        // Simulate a non-owner address trying to upgrade
        address unauthorizedUser = address(0x123);
        vm.prank(unauthorizedUser); // Change the msg.sender to unauthorizedUser
        vm.expectRevert(); // Expect revert with the Ownable error message
        upgrader.upgradeBox(proxy, address(box2));
    }
}
