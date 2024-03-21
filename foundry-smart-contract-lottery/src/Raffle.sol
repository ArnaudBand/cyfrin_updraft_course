// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
* @title A simple Raffle Contract
* @author Arnaud
* @notice This contract is for creating a sample raffle
* @dev Implements Chainlink VRFv2
*/

contract Raffle {
    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {}

    function pickWinner() public {}

    /** Getter function */
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }
}
