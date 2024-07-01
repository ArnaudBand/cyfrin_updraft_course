// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library OracleLib {

  error OracleLib__StalePriceCheck();

  uint256 private constant TIME_LIMIT = 3 hours;
    function staleCheckLatestRoundData(AggregatorV3Interface priceFeed)
        public
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            priceFeed.latestRoundData();
        
        uint256 secondSince = block.timestamp - updatedAt;

        if (secondSince > TIME_LIMIT) revert OracleLib__StalePriceCheck();

        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
