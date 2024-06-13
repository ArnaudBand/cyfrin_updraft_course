// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract DSCEngineTest is Test {
    DecentralizedStableCoin dsc;
    DSCEngine engine;
    HelperConfig config;

    address public ethUsdPriceFeed;
    address public btcUsdPriceFeed;
    address public weth;
    address public wbtc;
    uint256 public deployerKey;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10e18;
    uint256 public constant STARTING_ERC20_BALANCE = 10e18;
    uint256 public AMOUNT_TO_MINT = 10 ether;

    function setUp() public {
        DeployDSC deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth,, deployerKey) = config.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
    }

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
    }

    function testGetUsdValue() public view {
        uint256 ethAmount = 15e18;
        // 15e18 ETH * $2000/ETH = $30,000e18
        uint256 expectedUsd = 30000e18;
        uint256 usdValue = engine.getUsdValue(weth, ethAmount);
        console.log(usdValue);
        assertEq(usdValue, expectedUsd);
    }

    function testGetTokenAmountFromUsd() public view {
        uint256 usdAmount = 30000 ether;
        uint256 expectedTokenAmount = 15 ether;
        uint256 tokenAmount = engine.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(tokenAmount, expectedTokenAmount);
    }

    function testRevertIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);

        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertIfCollateralNotApproved() public {
        ERC20Mock rand = new ERC20Mock("RAN", "RANDOM", USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(DSCEngine.DSCEngine_NotAllowedToken.selector);
        engine.depositCollateral(address(rand), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralAndGetAcountInfo() public depositedCollateral {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInfo(USER);
        uint256 expectTotalMintedDsc = 0;
        uint256 expectedDepositAmount = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalDscMinted, expectTotalMintedDsc);
        assertEq(AMOUNT_COLLATERAL, expectedDepositAmount);
    }

    function testCanMintDsc() public depositedCollateral {
        vm.prank(USER);
        engine.mintDsc(AMOUNT_TO_MINT);

        uint256 balance = dsc.balanceOf(USER);
        assertEq(balance, AMOUNT_TO_MINT);
    }

    function testCanMintWithDepositedCollateral() public depositedCollateral {
        uint256 balance = dsc.balanceOf(USER);
        assertEq(balance, 0);
    }

    function testRevertMintDscIfAmountIsZero() public depositedCollateral {
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.mintDsc(0);
    }

    modifier depositedCollateralAndMintedDsc() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateralAndMintDsc(weth, AMOUNT_COLLATERAL, AMOUNT_TO_MINT);
        vm.stopPrank();
        _;
    }

    function testCanMintWithDepositedCollateralAndCheckBalance() public depositedCollateralAndMintedDsc {
        uint256 balance = dsc.balanceOf(USER);
        assertEq(balance, AMOUNT_TO_MINT);
    }

    function testCanMintWithDepositedCollateralAndCheckAccountInfo() public depositedCollateralAndMintedDsc {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInfo(USER);
        uint256 expectedTotalMintedDsc = AMOUNT_TO_MINT;
        uint256 expectedDepositAmount = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalDscMinted, expectedTotalMintedDsc);
        assertEq(AMOUNT_COLLATERAL, expectedDepositAmount);
    }

    function testMustRedeemMoreThanZero() public depositedCollateralAndMintedDsc {
        vm.startPrank(USER);
        dsc.approve(address(engine), AMOUNT_TO_MINT);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.redeemCollateralForDsc(weth, 0, AMOUNT_TO_MINT);
        vm.stopPrank();
    }

    function testMustRedeemMoreThanZeroDsc() public depositedCollateralAndMintedDsc {
        vm.startPrank(USER);
        dsc.approve(address(engine), AMOUNT_TO_MINT);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.redeemCollateralForDsc(weth, AMOUNT_COLLATERAL, 0);
        vm.stopPrank();
    }
}
