import { useState, useEffect, useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Box, Text, Button, Grid } from '@chakra-ui/react';
import Config from '../../../config.ts';
import ProviderContext from '../../../context/ProviderContext.ts';
import AccountContext from '../../../context/AccountContext.ts';
import Connect from '../../atoms/Connect/Connect';
import AuctionCard from '../../atoms/Auction/AuctionCard'; // Import AuctionCard
import { IAuction } from '../../atoms/Auction/auction.types';
import { parseAuctionFetchResponse } from './parseAuctionFetchResponse';

const Home = () => {
  const { address } = useContext(AccountContext);
  const { provider } = useContext(ProviderContext);
  const navigate = useNavigate();

  const [auctions, setAuctions] = useState<IAuction[]>([]);

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

  const handleCreateAuctionClick = () => {
    navigate('/create-auction'); // Redirection vers la page de création d'enchères
  };

  return (
    <Box textAlign="center" mt="50px" px={4}>

      {address && (
        <Box mt={8}>
          <Button onClick={handleCreateAuctionClick} colorScheme="blue" mb={4}>
            Create Auction
          </Button>
        </Box>
      )}

      <Box mt={8}>
        <Text fontSize="2xl" mb="4">Current Auctions</Text>
        {auctions.length === 0 ? (
          <Text>No auctions available.</Text>
        ) : (
          <Grid templateColumns="repeat(auto-fill, minmax(300px, 1fr))" gap={6}>
            {auctions.map((auction, index) => (
              <Box
                key={index}
                borderWidth="1px"
                borderRadius="lg"
                overflow="hidden"
                boxShadow="md"
                p={4}
                transition="transform 0.2s"
                _hover={{ transform: 'scale(1.05)' }}
              >
                <Link to={`/auction/${index}`}>
                  <AuctionCard auction={auction} /> {/* Use AuctionCard */}
                </Link>
              </Box>
            ))}
          </Grid>
        )}
      </Box>
    </Box>
  );
};

export default Home;