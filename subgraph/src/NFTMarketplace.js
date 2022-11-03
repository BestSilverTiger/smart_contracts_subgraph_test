export function handleItemListed(event) {
    const id = event.params.NFTAddress.toString()+
    '-'+
    event.params.tokenId.toString()+
    '-'+
    event.params.seller.toString();

    let item = ListedItem.load(id);
    if (!item) {
        item = new ListedItem(id);
        item.nftaddress = event.params.NFTAddress;
        item.tokenId = event.params.tokenId;
    }
    item.seller = event.params.seller;
    item.price = event.params.price;
    item.sold = false;
    item.cancelled = false;
    item.save();
}

export function handleItemBought(event) {
    const id = event.params.NFTAddress.toString()+
    '-'+
    event.params.tokenId.toString()+
    '-'+
    event.params.seller.toString();
    let item = ListedItem.load(id);
    if (item) {
        let buyHistory = new BuyHistory(id);
        buyHistory.tokenId = event.params.tokenId;
        buyHistory.seller = event.params.seller;
        buyHistory.buyer = event.params.buyer;
        buyHistory.price = event.params.price;
        buyHistory.timestamp = event.block.timestamp;
        buyHistory.save();
        item.sold = true;
        item.save();
    }
    
}

export function handleItemCancelled(event) {
    const id = event.params.NFTAddress.toString()+
    '-'+
    event.params.tokenId.toString()+
    '-'+
    event.params.seller.toString();

    let item = ListedItem.load(id);
    if (item) {
        item = new ListedItem(id);
        item.cancelled = true;
        item.save();
    }
}
