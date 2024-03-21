// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
* @title A simple Raffle Contract
* @author Arnaud
* @notice This contract is for creating a sample raffle
* @dev Implements Chainlink VRFv2
*/

contract Raffle {
    error Raffle__NotEnoughEthSent();

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;

    /** @Events */
    event Enteredraffle(address indexed player);

    constructor(uint256 entranceFee, uint256 _interval) {
        i_entranceFee = entranceFee;
        i_interval = _interval;
    }

    function enterRaffle() public payable {
        if(msg.value < i_entranceFee) revert Raffle__NotEnoughEthSent();

        s_players.push(payable(msg.sender));
        emit Enteredraffle(msg.sender);
    }

    function pickWinner() public {}

    /** Getter function */
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }
}
