// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/Ownable.sol";
import "./lib/IERC20.sol";
import "./lib/IERC721.sol";
import "./lib/IERC2981.sol";
import "./lib/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard, Ownable {
    // Structs
    struct Listing {
        uint256 price;
        address seller;
    }

    // Events
    event ItemListed(address NFTAddress, address seller, uint256 price, uint256 tokenId);

    event ItemCancelled(address NFTAddress, uint256 tokenId);

    event ItemBought(address NFTAddress, address seller, address buyer, uint256 price, uint256 tokenId);

    // Modifiers
    modifier notListed(
        address NFTAddress,
        uint256 tokenId
    ) {
        require(listings[NFTAddress][tokenId].seller == address(0), "ERC721: This NFT is already listed.");
        _;
    }

    modifier isNFTOwner(
        address NFTAddress,
        uint256 tokenId,
        address spender
    ) {
        require(IERC721(NFTAddress).ownerOf(tokenId) == spender, "ERC721: This user is not owner of this nft.");
        _;
    }

    modifier isListed(address NFTAddress, uint256 tokenId) {
        require(listings[NFTAddress][tokenId].seller != address(0), "ERC721: This NFT is not listed.");
        _;
    }

    // An ERC-20 token that is accepted as payment in the marketplace (e.g. WAVAX)
    IERC20 tokenToPay;

    mapping(address => mapping(uint256 => Listing)) private listings;

    constructor(address _tokenToPay) {
        tokenToPay = IERC20(_tokenToPay);
    }

    function listItem(
        address NFTAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        notListed(NFTAddress, tokenId)
        isNFTOwner(NFTAddress, tokenId, msg.sender)
    {
        require(price > 0, "Price must be above zero");
        require(
            IERC721(NFTAddress).getApproved(tokenId) == address(this),
            "Not approved for marketplace"
        );
        listings[NFTAddress][tokenId] = Listing(price, msg.sender);
        IERC721(NFTAddress).transferFrom(msg.sender, address(this), tokenId);
        emit ItemListed(NFTAddress, msg.sender, price, tokenId);
    }

    // Add nonReentrant modifier
    // when buyer call the buyToken function, token will be transferred to seller.
    // At the same time of pending tx, seller can call cancelListing function then seller will get Token but buyer won't receive the NFT.
    function cancelListing(address NFTAddress, uint256 tokenId)
        external
        isNFTOwner(NFTAddress, tokenId, msg.sender)
        isListed(NFTAddress, tokenId)
        nonReentrant
    {
        delete (listings[NFTAddress][tokenId]);
        IERC721(NFTAddress).transferFrom(address(this), msg.sender, tokenId);
        emit ItemCancelled(NFTAddress, tokenId);
    }

    // Add nonReentrant modifier
    // when buyer call the buyToken function, token will be transferred to seller.
    // At the same time of pending tx, seller can call cancelListing function then seller will get Token but buyer won't receive the NFT.
    function buyItem(address NFTAddress, uint256 tokenId)
        external
        isListed(NFTAddress, tokenId)
        nonReentrant
    {
        Listing memory listedItem = listings[NFTAddress][tokenId];
        require(tokenToPay.balanceOf(msg.sender) >= listedItem.price, "ERC20: Insufficent balance");  
        (address royaltyReceiver, uint256 royaltyAmount) = IERC2981(NFTAddress).royaltyInfo(tokenId, listedItem.price);
        IERC20(tokenToPay).transferFrom(
            msg.sender,
            royaltyReceiver,
            royaltyAmount
        );

        uint256 amountPaidToSeller = listedItem.price - royaltyAmount;
        IERC20(tokenToPay).transferFrom(
            msg.sender,
            listedItem.seller,
            amountPaidToSeller
        );

        delete (listings[NFTAddress][tokenId]);
        IERC721(NFTAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
        emit ItemBought(NFTAddress, listedItem.seller, msg.sender, listedItem.price, tokenId);
    }

    // Add nonReentrant modifier
    // when buyer call the buyToken function, token will be transferred to seller.
    // At the same time of pending tx, seller can call cancelListing function then seller will get Token but buyer won't receive the NFT.
    function updateListing(
        address NFTAddress,
        uint256 tokenId,
        uint256 newPrice
    )
        external
        isListed(NFTAddress, tokenId)
        isNFTOwner(NFTAddress, tokenId, msg.sender)
        nonReentrant
    {
        require(newPrice > 0, "Price must be above zero");
        listings[NFTAddress][tokenId].price = newPrice;
    }

    function getListing(address NFTAddress, uint256 tokenId)
        external
        view
        returns (Listing memory)
    {
        return listings[NFTAddress][tokenId];
    }
}
