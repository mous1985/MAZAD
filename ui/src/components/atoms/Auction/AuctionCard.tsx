import { Box, Image, Badge, Text, useColorMode } from '@chakra-ui/react';
import { IAuction } from './auction.types';

interface AuctionCardProps {
  auction: IAuction;
}

const AuctionCard = ({ auction }: AuctionCardProps) => {
  const { colorMode } = useColorMode(); // Détection du mode (clair ou sombre)

  return (
    <Box
      maxW="sm"
      borderRadius="lg"
      overflow="hidden"
      display="flex"
      flexDirection="column"
      bg={colorMode === 'dark' ? 'gray.800' : 'white'}
      boxShadow="md"
      border="1px solid"
      borderColor={colorMode === 'dark' ? 'gray.700' : 'gray.200'}
      transition="background-color 0.3s, border-color 0.3s"
    >
      {/* Image */}
      <Image
        src={auction.img || 'https://via.placeholder.com/200'}
        alt="Auction Image"
        width="100%"
        height="300px"
        objectFit="cover"
      />

      {/* Contenu */}
      <Box p="6" flex="1" display="flex" flexDirection="column" justifyContent="flex-end">
        {/* Badge et dates */}
        <Box display="flex" alignItems="baseline" mb={2}>
          <Badge borderRadius="full" px="2" colorScheme="teal">
            New Auction
          </Badge>
          <Box ml="3">
            <Text
              color={colorMode === 'dark' ? 'gray.400' : 'gray.600'}
              fontWeight="semibold"
              letterSpacing="wide"
              fontSize="xs"
              textTransform="uppercase"
            >
              Start: {new Date(auction.begin * 1000).toLocaleString()}
            </Text>
            <Text
              color={colorMode === 'dark' ? 'gray.400' : 'gray.600'}
              fontWeight="semibold"
              letterSpacing="wide"
              fontSize="xs"
              textTransform="uppercase"
              mt={1}
            >
              End: {new Date(auction.deadline * 1000).toLocaleString()}
            </Text>
          </Box>
        </Box>

        {/* Titre de l'enchère */}
        <Box
          mt="1"
          fontWeight="semibold"
          as="h4"
          lineHeight="tight"
          noOfLines={1}
          color={colorMode === 'dark' ? 'white' : 'gray.800'}
        >
          {auction.title}
        </Box>

        {/* Description */}
        <Box mt="2">
          <Text
            fontSize="sm"
            color={colorMode === 'dark' ? 'gray.300' : 'gray.700'}
          >
            Description: {auction.description}
          </Text>
        </Box>
      </Box>
    </Box>
  );
};

export default AuctionCard;
