// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(address dataFeedAdx) internal view returns (uint256) {
        AggregatorV3Interface dataFeed = AggregatorV3Interface(dataFeedAdx);
        (, int256 answer, , , ) = dataFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(
        uint256 ethAmountUserGave,
        address dataFeedAdx
    ) internal view returns (uint256) {
        uint256 usdPrice = getPrice(dataFeedAdx);
        // division since they are two 1e18 numbers being multiplied
        uint256 ethAmountInUsd = (usdPrice * ethAmountUserGave) / 1e18;
        return ethAmountInUsd;
    }

    function getDataFeedVersion(
        address dataFeedAdx
    ) internal view returns (uint256) {
        return AggregatorV3Interface(dataFeedAdx).version();
    }
}
