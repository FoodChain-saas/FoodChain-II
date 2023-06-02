//SPDX-LIcense_Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721Token is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("FoodChain", "FDC") {}

    function mintToken(address receipient, string memory tokenURI) external
    returns(uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(receipient, newTokenId);
        // _setTokenURI(newTokenId, tokenURI);
        return newTokenId;
    }
}