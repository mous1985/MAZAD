import { IAuction } from '../../atoms/Auction/auction.types';

export interface IAuctionDetailsProps {
    auction: IAuction;
    onBidPlaced: () => void;
}
