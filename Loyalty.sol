// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./MyERC721.sol";

contract LoyaltyPointTracker is ChainlinkClient, MyERC721Token{
    using Chainlink for Chainlink.Request;

    address public owner;
    uint256 public pointConversionRate;
    mapping(address => uint) public loyaltyPoints;

    event PointsEarned(address indexed user, uint256 points);
    event PointsRedeemed(address indexed user, uint256 points);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor(uint256 _pointConversionRate, address _linkToken, address _oracle) {
        owner = msg.sender;
        pointConversionRate = _pointConversionRate;
        setChainlinkToken(_linkToken);
        setChainlinkOracle(_oracle);
    }

    //Points Conversion rate to be set by the owner of the NFT
    function setConversionRate(uint _pointConversionRate) public onlyOwner {
        pointConversionRate = _pointConversionRate;
    }

    //Earning loyalty Points
    function earnPoints(uint orderAmount) external {
        uint pointsEarned = orderAmount / pointConversionRate;
        loyaltyPoints[msg.sender] += pointsEarned;
        emit PointsEarned(msg.sender, pointsEarned);
    }

    //Redeeming points
    function redeemPoints(uint pointsToRedeem) external {
        require(loyaltyPoints[msg.sender] >= pointsToRedeem, "Insufficient loyalty points");

        require(msg.sender == owner, "This food point does not belong to you");
        loyaltyPoints[msg.sender] -= pointsToRedeem;
        emit PointsRedeemed(msg.sender, pointsToRedeem);
    }


    //Getting the Chainlink Oracles
    function getCurrencyPrice() private returns (uint256) {
        // Chainlink request details
        Chainlink.Request memory request = buildChainlinkRequest(
            'ca98366cc7314957b8c012c72f05aeeb', //Chainlink Job ID
            address(this),
            this.receiveCurrencyPrice.selector
        );
        request.add("get",
        "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");
        //API endpoint for fetching the currency price
        request.add('path', 'RAW,ETH,USD,VOLUME24HOUR');
        request.addInt("times", 10**18);

        // Send the Chainlink request
        sendChainlinkRequest(request, (1 * LINK_DIVISIBILITY) / 10);
    }

    function receiveCurrencyPrice(bytes32 _requestId, int _price) public recordChainlinkFulfillment(_requestId) {
        // Use the received price data as needed
        // Update the loyalty points conversion rate or perform other actions
        pointConversionRate = uint(_price);
    }

    function updateConversionRate() external {
        getCurrencyPrice();
    }
}
