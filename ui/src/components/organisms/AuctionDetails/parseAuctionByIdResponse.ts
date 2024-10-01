import { IAuction } from "../../atoms/Auction/auction.types.ts";

export const parseAuctionByIdResponse = (response: string): IAuction => {
    // Utiliser le même regex pour capturer la partie entre guillemets et parenthèses
    const regex = /\("(.*)".*\)/;
    const match = response.match(regex);

    if (!match || match.length < 2) {
        throw new Error('Invalid auction response');
    }

    // Nettoyer la chaîne pour enlever les guillemets échappés
    const cleanResponse = match[1].replace(/\\"/g, '"');

    // Parser le JSON propre
    return JSON.parse(cleanResponse);
};
