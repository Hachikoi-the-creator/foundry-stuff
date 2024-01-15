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
import {PriceConverter} from "./PriceConverter.sol";

contract FoundMe {
    using PriceConverter for uint256;
    address immutable ownerAdx;
    address dataFeedAdx;
    uint256 public constant minimunUSD = 5e18;
    address[] public foundersArr;
    mapping(address => uint256) addressToUSDGifted;

    // mapping (address founder => uint amountGifted) addressToUSDGifted;

    constructor(address _vrfContractAdx) {
        ownerAdx = msg.sender;
        dataFeedAdx = _vrfContractAdx;
    }

    function fund() public payable {
        // allow users to send eth
        // have a minimun eth amount based of USD
        uint256 amountGifted = msg.value.getConversionRate(dataFeedAdx);
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
    }

    modifier OnlyOwner() {
        require(msg.sender == ownerAdx, "You aint no owner go away mf");
        _;
    }
}
