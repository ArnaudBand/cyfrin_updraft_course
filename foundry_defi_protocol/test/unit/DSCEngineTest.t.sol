// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockFailedMintDSC} from "../mocks/MockFailedMintDSC.sol";
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
    address public liquidator = makeAddr("liquidator");
    uint256 public constant AMOUNT_COLLATERAL = 10e18;
    uint256 public constant STARTING_ERC20_BALANCE = 10e18;
    uint256 public AMOUNT_TO_MINT = 100 ether;
    uint256 public collateralToCover = 20 ether;

    function setUp() public {
        DeployDSC deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc, deployerKey) = config.activeNetworkConfig();
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

    // function testMustRedeemMoreThanZero() public depositedCollateralAndMintedDsc {
    //     vm.startPrank(USER);
    //     dsc.approve(address(engine), AMOUNT_TO_MINT);
    //     vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
    //     engine.redeemCollateralForDsc(weth, 0, AMOUNT_TO_MINT);
    //     vm.stopPrank();
    // }

    // function testMustRedeemMoreThanZeroDsc() public depositedCollateralAndMintedDsc {
    //     vm.startPrank(USER);
    //     dsc.approve(address(engine), AMOUNT_TO_MINT);
    //     vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
    //     engine.redeemCollateralForDsc(weth, AMOUNT_COLLATERAL, 0);
    //     vm.stopPrank();
    // }

    function testRevertIfMintAmountBreaksHealthFactor() public depositedCollateral {
        (, int256 price,,,) = MockV3Aggregator(ethUsdPriceFeed).latestRoundData();
        AMOUNT_TO_MINT =
            (AMOUNT_COLLATERAL * (uint256(price) * engine.getAdditionalFeedPrecision())) / engine.getPrecision();
        vm.startPrank(USER);
        uint256 expectedHealthFactor =
            engine.calculateHealthFactor(AMOUNT_TO_MINT, engine.getUsdValue(weth, AMOUNT_COLLATERAL));
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__BreaksHealthFactor.selector, expectedHealthFactor));
        engine.mintDsc(AMOUNT_TO_MINT);
        vm.stopPrank();
    }

    function testRevertsIfMintFails() public {
        MockFailedMintDSC failedDsc = new MockFailedMintDSC();
        DSCEngine mockengine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(failedDsc));
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(mockengine), AMOUNT_COLLATERAL);
        vm.expectRevert();
        mockengine.depositCollateralAndMintDsc(weth, AMOUNT_COLLATERAL, AMOUNT_TO_MINT);
        vm.stopPrank();
    }

    function testCantBurnMoreThanUserHas() public {
        vm.startPrank(USER);
        vm.expectRevert();
        engine.burnDsc(AMOUNT_TO_MINT);
    }

    function testCanBurnDsc() public depositedCollateralAndMintedDsc {
        vm.startPrank(USER);
        dsc.approve(address(engine), AMOUNT_TO_MINT);
        engine.burnDsc(AMOUNT_TO_MINT);
        vm.stopPrank();

        uint256 userBalance = dsc.balanceOf(USER);
        assertEq(userBalance, 0);
    }

    function testReportsHealthFactor() public depositedCollateralAndMintedDsc {
        uint256 healthFactor = engine.getHealthFactor(USER);
        assertEq(
            healthFactor, engine.calculateHealthFactor(AMOUNT_TO_MINT, engine.getUsdValue(weth, AMOUNT_COLLATERAL))
        );
    }

    function testCantLiquidateGoodHealthFactor() public depositedCollateralAndMintedDsc {
        ERC20Mock(weth).mint(USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateralAndMintDsc(weth, AMOUNT_COLLATERAL, AMOUNT_TO_MINT);
        dsc.approve(address(engine), AMOUNT_TO_MINT);
        vm.expectRevert(DSCEngine.DSCEngine__HealthFactor.selector);
        engine.liquidate(weth, USER, AMOUNT_TO_MINT);
        vm.stopPrank();
    }

    modifier liquidated() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateralAndMintDsc(weth, AMOUNT_COLLATERAL, AMOUNT_TO_MINT);
        vm.stopPrank();
        int256 ethUsdUpdatedPrice = 18e8; // 1 ETH = $18

        MockV3Aggregator(ethUsdPriceFeed).updateAnswer(ethUsdUpdatedPrice);
        uint256 userHealthFactor = engine.getHealthFactor(USER);

        ERC20Mock(weth).mint(liquidator, collateralToCover);

        vm.startPrank(liquidator);
        ERC20Mock(weth).approve(address(engine), collateralToCover);
        engine.depositCollateralAndMintDsc(weth, collateralToCover, AMOUNT_TO_MINT);
        dsc.approve(address(engine), AMOUNT_TO_MINT);
        engine.liquidate(weth, USER, AMOUNT_TO_MINT); // We are covering their whole debt
        vm.stopPrank();
        _;
    }

    function testCanLiquidate() public depositedCollateralAndMintedDsc {
        uint256 userBalance = dsc.balanceOf(USER);
        assertEq(userBalance, AMOUNT_TO_MINT);
    }

    function testCanLiquidateAndCheckHealthFactor() public depositedCollateralAndMintedDsc {
        uint256 healthFactor = engine.getHealthFactor(USER);
        assertEq(
            healthFactor, engine.calculateHealthFactor(AMOUNT_TO_MINT, engine.getUsdValue(weth, AMOUNT_COLLATERAL))
        );
    }

    function testLiquidatorTakesOnUserDebt() public liquidated {
        (uint256 liquidatorDscBalance, uint256 liquidatorCollateralValueInUsd) = engine.getAccountInfo(liquidator);
        uint256 expectedLiquidatorCollateralValueInUsd = engine.getUsdValue(weth, collateralToCover);
        assertEq(liquidatorDscBalance, AMOUNT_TO_MINT);
        assertEq(liquidatorCollateralValueInUsd, expectedLiquidatorCollateralValueInUsd);
    }

    function testLiquidatationPayOutIsCorrect() public liquidated {
        uint256 liquidatorWethBalance = ERC20Mock(weth).balanceOf(liquidator);
        uint256 expectedWeth = engine.getTokenAmountFromUsd(weth, AMOUNT_TO_MINT)
            + (engine.getTokenAmountFromUsd(weth, AMOUNT_TO_MINT) / engine.getLiquidationBonus());
        console.log("ex", expectedWeth);
        uint256 hardCodedExpected = 6_111_111_111_111_111_110;
        assertEq(liquidatorWethBalance, hardCodedExpected);
        assertEq(liquidatorWethBalance, expectedWeth);
    }

    function testMintDsc() public depositedCollateral {
        vm.startPrank(USER);

        engine.mintDsc(AMOUNT_TO_MINT);

        (uint256 totalDscMinted,) = engine.getAccountInfo(USER);
        assertEq(totalDscMinted, AMOUNT_TO_MINT);

        vm.stopPrank();
    }

    function testRedeemCollateral() public depositedCollateral {
        vm.startPrank(USER);

        uint256 amountToRedeem = 5e18;
        engine.redeemCollateral(weth, amountToRedeem);

        uint256 remainingCollateral = engine.getCollateralBalanceOfUser(USER, weth);
        assertEq(remainingCollateral, AMOUNT_COLLATERAL - amountToRedeem);

        vm.stopPrank();
    }

    function testDepositCollateralAndMintDsc() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);

        engine.depositCollateralAndMintDsc(weth, AMOUNT_COLLATERAL, AMOUNT_TO_MINT);

        // Check collateral and DSC minted
        (uint256 totalDscMinted,) = engine.getAccountInfo(USER);
        assertEq(totalDscMinted, AMOUNT_TO_MINT);
        assertEq(engine.getCollateralBalanceOfUser(USER, weth), AMOUNT_COLLATERAL);

        vm.stopPrank();
    }

    function testHealthFactorCanGoBelowOne() public depositedCollateralAndMintedDsc {
        int256 updateEthPriceInUsd = 10e8;
        MockV3Aggregator(ethUsdPriceFeed).updateAnswer(updateEthPriceInUsd);
        uint256 healthFactor = engine.getHealthFactor(USER);
        assertEq(
            healthFactor, engine.calculateHealthFactor(AMOUNT_TO_MINT, engine.getUsdValue(weth, AMOUNT_COLLATERAL))
        );
    }

    function testGetCollateralTokens() public view {
        address[] memory collateralTokens = engine.getCollateralTokens();
        assertEq(collateralTokens[0], weth);
    }

    function testGetCollateralTokensLength() public view {
        address[] memory collateralTokens = engine.getCollateralTokens();
        assertEq(collateralTokens.length, 2);
    }

    function testGetCollateralTokensLengthAfterAddingCollateral() public {
        vm.startPrank(USER);
        ERC20Mock(weth).mint(USER, AMOUNT_TO_MINT);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateral(weth, AMOUNT_COLLATERAL);
        address[] memory collateralTokens = engine.getCollateralTokens();
        assertEq(collateralTokens.length, 2);
        vm.stopPrank();
    }

    function testGetCollateralTokensLengthAfterAddingCollateralAndMinting() public {
        vm.startPrank(USER);
        ERC20Mock(weth).mint(USER, AMOUNT_TO_MINT);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateralAndMintDsc(weth, AMOUNT_COLLATERAL, AMOUNT_TO_MINT);
        address[] memory collateralTokens = engine.getCollateralTokens();
        assertEq(collateralTokens.length, 2);
        vm.stopPrank();
    }

    function testGetCollateralTokenPriceFeed() public view {
        address priceFeeds = engine.getCollateralTokenPriceFeed(weth);
        assertEq(priceFeeds, ethUsdPriceFeed);
    }

    function testGetMinHealthFactor() public view {
        uint256 minHealthFactor = engine.getMinHealthFactor();
        assertEq(minHealthFactor, 1e18);
    }

    function testGetLiquidationThresHold() public view {
        uint256 liquidationThreshold = engine.getLiquidationThreshold();
        assertEq(liquidationThreshold, 50);
    }

    function testGetAccountCollateralValueFromInfo() public depositedCollateral {
        (, uint256 collateralValueInUsd) = engine.getAccountInfo(USER);
        uint256 expectedCollateralValueInUsd = engine.getUsdValue(weth, AMOUNT_COLLATERAL);
        assertEq(collateralValueInUsd, expectedCollateralValueInUsd);
    }

    function testGetDsc() public view {
        address dscAddress = engine.getDsc();
        assertEq(dscAddress, address(dsc));
    }

    function testGetLiquidationPrecision() public view {
        uint256 liquidationPrecision = engine.getLiquidationPrecision();
        assertEq(liquidationPrecision, 100);
    }

    function testGetLiquidationBonus() public view {
        uint256 liquidationBonus = engine.getLiquidationBonus();
        assertEq(liquidationBonus, 10);
    }

    function testGetAdditionalFeedPrecision() public view {
        uint256 additionalFeedPrecision = engine.getAdditionalFeedPrecision();
        assertEq(additionalFeedPrecision, 1e10);
    }

    function testGetPrecision() public view {
        uint256 precision = engine.getPrecision();
        assertEq(precision, 1e18);
    }
}
