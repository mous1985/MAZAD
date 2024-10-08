export interface IAuction {
  title: string;
  description: string;
  begin: number; // timestamp UNIX
  deadline: number; // timestamp UNIX
  owner: string;
  firstPrice: number;
  bids: number;
  img?: string;
}


export interface IAuctionProps {
  auction: IAuction;
}
