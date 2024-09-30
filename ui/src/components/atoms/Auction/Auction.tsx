import { FC } from 'react';
import { Box, Text } from '@chakra-ui/react';
import { IAuction } from './auction.types'; 

interface AuctionProps {
  auction: IAuction;
}

const Auction: FC<AuctionProps> = ({ auction }) => {
  const priceInGNOT = auction.firstPrice / 1_000_000; // Conversion 

  return (
    <Box borderWidth="1px" borderRadius="lg" overflow="hidden" p={4} mb={4}>
      <Text fontSize="2xl" fontWeight="bold">
        {auction.title}
      </Text>
      <Text mt={2}>Owner: {auction.owner}</Text>
      <Text mt={2}>Description: {auction.description}</Text>
      <Text mt={2}>Start Time: {new Date(auction.begin * 1000).toLocaleString()}</Text>
      <Text mt={2}>End Time: {new Date(auction.deadline * 1000).toLocaleString()}</Text>
      {/* Conversion  ugnot  GNOT */}
      <Text mt={2}>
        Starting Price: {priceInGNOT} GNOT
      </Text>
      <Text mt={2}>Number of Bids: {auction.bids}</Text>
    </Box>
  );
};

export default Auction;
