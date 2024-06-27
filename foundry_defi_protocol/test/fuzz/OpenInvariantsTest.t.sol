// // SPDX-License-Identifier: SEE LICENSE IN LICENSE
// pragma solidity ^0.8.25;

// import {Test} from "forge-std/Test.sol";
// import {StdInvariant} from "forge-std/StdInvariant.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";

// contract OpenInvariantsTest is StdInvariant, Test {
//     DSCEngine engine;
//     DecentralizedStableCoin dsc;
//     DeployDSC deployer;
//     HelperConfig config;
//     address weth;
//     address wbtc;

//     function setUp() external {
//         deployer = new DeployDSC();
//         (dsc, engine, config) = deployer.run();
//         (, , weth, wbtc, ) = config.activeNetworkConfig();
//         targetContract(address(engine));
//     }

//     function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
//       uint256 totalSupply = dsc.totalSupply();
//       uint256 totalWethDeposited = IERC20(weth).balanceOf(address(engine));
//       uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(engine));

//       uint256 wethValue = engine.getUsdValue(weth, totalWethDeposited);
//       uint256 wbtcValue = engine.getUsdValue(wbtc, totalWbtcDeposited);

//       assert(wethValue + wbtcValue >= totalSupply);
//     }
// }
