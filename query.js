// The tokenId, list price and seller of all tokens currently listed for a particular NFT contract
const nftaddress = "";
const getAllListedTokenQuery = `
        {
            listeditem(
                where: {
                    sold: false
                    cancelled: false
                    nftaddress: ${nftaddress}
                } 
            ) {
                id
                price
                seller
            }   
        }
        `;

// The last sold price for a particular tokenId corresponding to an NFT contract.
const tokenId = "";
const getLastestSellPrice = `
        {
            buyhistory(
                where: {
                    tokenId: ${tokenId}
                } 
                orderby timestamp
                orderDirection desc
                first 1
            ) {
                price
            }   
        }
        `;

// The highest sold price of a token in the last 24 hours for a particular NFT collection
const timestamp = new Date().getTime()/1000 - 24 * 60 * 60; 
const getTopPriceLast24hour = `
        {
            buyhistory(
                where: {
                    timestamp_gt: ${timestamp}
                    nftaddress: ${nftaddress}
                } 
                orderby price
                orderDirection desc
            ) {
                price
            }   
        }
        `;

// The highest sold price of a token in the last 24 hours for a particular NFT collection
const getFloorPriceLast24hour = `
        {
            buyhistory(
                where: {
                    timestamp_gt: ${timestamp}
                    nftaddress: ${nftaddress}
                } 
                orderby price
            ) {
                price
            }   
        }
        `;

// Get buy history in the last 24 hours for a particular NFT collection
const getBuyhistoryLast24hour = `
        {
            buyhistory(
                where: {
                    timestamp_gt: ${timestamp}
                    nftaddress: ${nftaddress}
                } 
                orderby price
            ) {
                price
            }   
        }
        `;

