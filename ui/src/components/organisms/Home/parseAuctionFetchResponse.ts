import { IAuction } from "../../atoms/Auction/auction.types.ts";
export const parseAuctionFetchResponse = (response: string): IAuction[] => {

    const regex = /\("(.*)".*\)/;
    const match = response.match(regex);

    if (!match || match.length < 2) {
        throw new Error('Invalid auction response');
    }
    const cleanResponse: string = match[1].replace(/\\"/g, '"');

    return JSON.parse(cleanResponse);
};

