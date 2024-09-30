import { useState, useEffect, useContext } from 'react';
import { Box, Text, Button } from '@chakra-ui/react';
import Config from '../../../config.ts';
import ProviderContext from '../../../context/ProviderContext.ts';
import AccountContext from '../../../context/AccountContext.ts';
import Connect from '../../atoms/Connect/Connect';
import CreateAuctionForm from '../../atoms/Auction/CreateAuction';
import Auction from '../../atoms/Auction/Auction';
import { IAuction } from '../../atoms/Auction/auction.types';
import { parseAuctionFetchResponse } from './parseAuctionFetchResponse';

const Home = () => {
  const { address } = useContext(AccountContext);
  const { provider } = useContext(ProviderContext);

  const [showForm, setShowForm] = useState(false);
  const [auctions, setAuctions] = useState<IAuction[]>([]);

  // Fetch all auctions from the Realm
  const fetchAuctions = async () => {
    if (!provider) {
      throw new Error('Invalid chain RPC URL');
    }

    try {
      const response: string = await provider.evaluateExpression(
        Config.REALM_PATH,
        `GetAuctions()`,
      );

      const auctionList = parseAuctionFetchResponse(response);
      setAuctions(auctionList);
    } catch (error) {
      console.error('Error fetching auctions:', error);
    }
  };

  useEffect(() => {
    fetchAuctions();
  }, []);

  const toggleForm = () => {
    setShowForm((prev) => !prev);
  };

  const handleAuctionCreated = () => {
    fetchAuctions();
  };

  return (
    <Box textAlign="center" mt="50px">
      <Text fontSize="4xl" mb="20px">
        MAZAD
      </Text>

      {!address ? (
        <Connect />
      ) : (
        <Text color="green.500">CONNECTED</Text>
      )}

      {address && (
        <Box mt={8}>
          <Button onClick={toggleForm} colorScheme="blue" mb={4}>
            {showForm ? 'Hide Create Auction Form' : 'Create Auction'}
          </Button>

          {showForm && <CreateAuctionForm onAuctionCreated={handleAuctionCreated} />}
        </Box>
      )}

      <Box mt={8}>
        <Text fontSize="2xl" mb="4">
          Current Auctions
        </Text>
        {auctions.length === 0 ? (
          <Text>No auctions available.</Text>
        ) : (
          auctions.map((auction, index) => (
            <Auction key={index} auction={auction} />
           
          ))
        )}
      </Box>
    </Box>
  );
};

export default Home;

