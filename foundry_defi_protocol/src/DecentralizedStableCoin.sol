// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Decentralized Stable Coin
 * @author Arnaud
 * Collateral: Exogenous (ETH & BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged to USD
 *
 * This is the contract meant to be governed by DDSCEngine. This contract is the ERC20 implementation of our stablecoin system.
 */
contract DecentralizedStableCoin is ERC20Burnable, Ownable {

  error DecentralizedStableCoin__MustBeMoreThanZero();
  error DecentralizedStableCoin__BurnAmountExceedsBalance();
  
  constructor() ERC20("DecentralizedStableCoin", "DSC") {}

  function burn(uint256 _amount) public override onlyOwner {
    uint256 balance = balanceOf(msg.sender);
    if (_amount <= 0) revert DecentralizedStableCoin__MustBeMoreThanZero();
    if (balance < _amount) revert DecentralizedStableCoin__BurnAmountExceedsBalance();
    super.burn(_amount);
  }
}
