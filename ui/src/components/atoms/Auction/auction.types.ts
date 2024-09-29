export interface IAuction {
    id: string;
    description: string;
    owner: string;
    currentPrice: number;
    startTime: number;
    endTime: number;
  }
  
  export interface IAuctionProps {
    auction: IAuction;
  }
  
  // Format the price (if necessary)
  export const formatPrice = (price: number): string => {
    return `${price.toFixed(2)} GNOT`;
  };
  