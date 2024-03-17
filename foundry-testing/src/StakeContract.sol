// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakeContract {
    mapping(address => uint256) public s_balance;

    function stake(uint256 amount, address token) external returns (bool) {
        s_balance[msg.sender] = s_balance[msg.sender] + amount;
        //  call the transfer function of an erc20 token
        () = IERC20(token).transferFrom(msg.sender, address(this), amount);
    }
}
