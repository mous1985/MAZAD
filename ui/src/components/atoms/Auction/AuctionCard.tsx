import React from 'react';
import { Box, Image, Badge, Text } from '@chakra-ui/react';
import { IAuction } from './auction.types';

interface AuctionCardProps {
    auction: IAuction;
}

const AuctionCard = ({ auction }: AuctionCardProps) => {
    return (
        <Box maxW='sm' borderRadius='lg' overflow='hidden' display='flex' flexDirection='column'>
            <Image src={auction.img || 'https://via.placeholder.com/200'} alt='Auction Image' width='100%' height='300px' objectFit='cover' />

            <Box p='6' flex='1' display='flex' flexDirection='column' justifyContent='flex-end'>
                <Box display='flex' alignItems='baseline'>
                    <Badge borderRadius='full' px='2' colorScheme='teal'>
                        New Auction
                    </Badge>
                    <Box
                        color='gray.500'
                        fontWeight='semibold'
                        letterSpacing='wide'
                        fontSize='xs'
                        textTransform='uppercase'
                        ml='2'
                    >
                        {new Date(auction.begin * 1000).toLocaleString()} - {new Date(auction.deadline * 1000).toLocaleString()}
                    </Box>
                </Box>
                <Box
                    mt='1'
                    fontWeight='semibold'
                    as='h4'
                    lineHeight='tight'
                    noOfLines={1}
                >
                    {auction.title}
                </Box>
                <Box>
                    <Text>Description: {auction.description}</Text>
                </Box>
            </Box>
        </Box>
    );
};

export default AuctionCard;