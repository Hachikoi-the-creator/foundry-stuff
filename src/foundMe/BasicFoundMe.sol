// SPDX-License-Identifier: MIT
/*
- Get founds from users
- Withdraw founds (only owner)
- Set a minimun funding value in USD
*/
// USD/ETH @SEPOLIA 0x694AA1769357215DE4FAC081bf1f309aDC325306

pragma solidity ^0.8.18;

// same as import {MyTsType} from "./types.ts" in JS
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FoundMe {
    address immutable ownerAdx;
    uint256 public constant minimunUSD = 5e18;
    AggregatorV3Interface internal dataFeed;
    address[] public foundersArr;
    mapping(address => uint) addressToUSDGifted;

    // mapping (address founder => uint amountGifted) addressToUSDGifted;

    constructor(address _vrfContractAdx) {
        ownerAdx = msg.sender;
        dataFeed = AggregatorV3Interface(_vrfContractAdx);
    }

    function fund() public payable {
        // allow users to send eth
        // have a minimun eth amount based of USD
        uint amountGifted = getConversionRate(msg.value);
        require(
            amountGifted > minimunUSD,
            "Didn't send enough money for me to even blink an eye, send more of fuck off"
        );
        foundersArr.push(msg.sender);
        addressToUSDGifted[msg.sender] += amountGifted;
    }

    function withdraw(address payable contractOwner) public payable OnlyOwner {
        (bool sent /*bytes memory data*/, ) = contractOwner.call{
            value: address(this).balance
        }("");
        require(
            sent,
            "Naur bruv you fucked up, now the ether is property of the chain!!"
        );

        // Reset all founding history
        for (uint i = 0; i < foundersArr.length; i++) {
            if (addressToUSDGifted[foundersArr[i]] > 0)
                delete addressToUSDGifted[foundersArr[i]];
        }
        delete foundersArr;
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = dataFeed.latestRoundData();
        // * 1e10 so decimals match between price
        // dataFeed.decimals(); = 8
        // and decimals in eth msg.value = 18
        // so in the end I'd need this x5 in order to succesfully found the contract?
        return uint256(answer * 1e10);
    }

    function getConversionRate(
        uint256 ethAmountUserGave
    ) public view returns (uint256) {
        uint256 usdPrice = getPrice();
        // division since they are two 1e18 numbers being multiplied
        uint256 ethAmountInUsd = (usdPrice * ethAmountUserGave) / 1e18;
        return ethAmountInUsd;
    }

    modifier OnlyOwner() {
        _;
    }

    // * Testing functions, remove later
    function changeVRFContractAdx(address _contractAdx) public OnlyOwner {
        dataFeed = AggregatorV3Interface(_contractAdx);
    }
}
