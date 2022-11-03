// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/IERC20.sol";
import "./lib/ERC721Royalty.sol";
import "./lib/Counters.sol";
import "./lib/Ownable.sol";

contract PorblesNFT is ERC721Royalty{
    IERC20 public wavax;

    uint256 tokenPrice;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(
        address _wavax,
        uint256 _tokenPrice
    ) {
        _tokenIds = 0;
        wavax = IERC20(_wavax);
        tokenPrice = _tokenPrice*10**18;
    }

    /**
     * @dev Mint
     */

    function mint(string memory tokenURI) public returns (uint) {
        require(wavax.balanceOf(msg.sender) >= tokenPrice, "ERC20: Insufficent balance");
        wavax.transferFrom(msg.sender(), owner(), tokenPrice);
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }

    /**
     * @dev setDefaultRoyalty
     */

    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator) public {
        _setDefaultRoyalty(owner(), _feeNumerator);
    }

}