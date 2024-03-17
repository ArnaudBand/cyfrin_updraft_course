// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/PriceConsumerV3.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

contract PriceConsumerTest is Test {
    PriceConsumerV3 public priceConsumer;
    MockV3Aggregator public mockV3Aggregator;
    uint8 public DECIMALS = 18;
    int256 public INIT_ANSWER = 1 * 10 ** 18;

    function setUp() public {
        mockV3Aggregator = new MockV3Aggregator(DECIMALS, INIT_ANSWER);
        priceConsumer = new PriceConsumerV3(address(mockV3Aggregator));
    }

    function testConsumerReturnsStartingValue() public {
        int256 price = priceConsumer.getLatestPrice();
        assertTrue(price == INIT_ANSWER);
    }
}
