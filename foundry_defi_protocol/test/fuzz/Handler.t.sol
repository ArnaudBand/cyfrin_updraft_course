// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

contract Handler is Test {

  DSCEngine engine;
  DecentralizedStableCoin dsc;

  ERC20Mock weth;
  ERC20Mock wbtc;

  uint256 MAX_DEPOSIT_SIZE = type(uint96).max; // The max uint96 value

  constructor(DSCEngine _engine, DecentralizedStableCoin _dsc) {
    engine = _engine;
    dsc = _dsc;

    address[] memory collateralTokens = engine.getCollateralTokens();
    weth = ERC20Mock(collateralTokens[0]);
    wbtc = ERC20Mock(collateralTokens[1]);
  }

  // redeem collateral <-
  function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);
    ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
    vm.startPrank(msg.sender);
    collateral.mint(msg.sender, amountCollateral);
    collateral.approve(address(engine), amountCollateral);
    engine.depositCollateral(address(collateral), amountCollateral);
    vm.stopPrank();
  }

  function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
    uint256 maxCollateral = engine.getCollateralBalanceOfUser(msg.sender, address(collateral));
    amountCollateral = bound(amountCollateral, 1, maxCollateral);
    if (amountCollateral == 0) return;

    engine.redeemCollateral(address(collateral), amountCollateral);
  }

  function _getCollateralFromSeed(uint256 seed) private view returns(ERC20Mock) {
    return seed % 2 == 0 ? weth : wbtc;
  }
}