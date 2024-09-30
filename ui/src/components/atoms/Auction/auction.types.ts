export interface IAuction {
  title: string;
  description: string;
  begin: number; // timestamp UNIX
  deadline: number; // timestamp UNIX
  owner: string;
  firstPrice: number;
  bids: number;
}


export interface IAuctionProps {
  auction: IAuction;
}
