import { useParams } from 'react-router-dom';
import { useState, useEffect, useContext } from 'react';
import { Box, Text, Input, Button, useToast, Image } from '@chakra-ui/react';
import Config from '../../../config.ts';
import ProviderContext from '../../../context/ProviderContext.ts';
import AccountContext from '../../../context/AccountContext.ts';
import { IAuction } from '../../atoms/Auction/auction.types';
import { AdenaService } from '../../../services/adena/adena.ts';
import { EMessageType } from '../../../services/adena/adena.types.ts';
import { parseAuctionByIdResponse } from './parseAuctionByIdResponse.ts';

const AuctionDetails = () => {
    const { id } = useParams<{ id: string }>();
    const { provider } = useContext(ProviderContext);
    const { address } = useContext(AccountContext);
    const [auction, setAuction] = useState<IAuction | null>(null);
    const [bidAmount, setBidAmount] = useState<number>(0);
    const toast = useToast();

    // Function to fetch auction details
    const fetchAuctionDetails = async () => {
        if (!provider) {
            throw new Error('Invalid chain RPC URL');
        }

        try {
            const response = await provider.evaluateExpression(
                Config.REALM_PATH,
                `GetAuctionById(${id})`,
            );

            const auctionDetails = parseAuctionByIdResponse(response);
            if (auctionDetails) {
                setAuction(auctionDetails);
            } else {
                console.error('No auction details found');
            }
        } catch (error) {
            console.error('Error fetching auction details:', error);
        }
    };

    const handleBid = async () => {
        if (!provider || !address) {
            toast({
                title: 'Connection Error',
                description: 'Please connect your wallet first.',
                status: 'error',
                duration: 5000,
                isClosable: true,
            });
            return;
        }

        try {
            console.log(`Placing bid for auction ID: ${id}, bid amount: ${bidAmount} GNOT`);

            const bidInUgnot = bidAmount * 1_000_000;

            await AdenaService.sendTransaction(
                [
                    {
                        type: EMessageType.MSG_CALL,
                        value: {
                            caller: address,
                            send: '',
                            pkg_path: Config.REALM_PATH,
                            func: 'AddBid',
                            args: [`${id}`, `${bidInUgnot}`],
                        },
                    },
                ],
                2000000
            );

            toast({
                title: 'Bid Placed',
                description: 'Your bid has been placed successfully!',
                status: 'success',
                duration: 5000,
                isClosable: true,
            });
        } catch (error) {
            console.error('Error placing bid:', error);
            toast({
                title: 'Error',
                description: 'There was an error placing your bid.',
                status: 'error',
                duration: 5000,
                isClosable: true,
            });
        }
    };

    const handleEndAuction = async () => {
        if (!provider || !address) {
            toast({
                title: 'Connection Error',
                description: 'Please connect your wallet first.',
                status: 'error',
                duration: 5000,
                isClosable: true,
            });
            return;
        }

        try {
            console.log(`Ending auction with ID: ${id}`);

            await AdenaService.sendTransaction(
                [
                    {
                        type: EMessageType.MSG_CALL,
                        value: {
                            caller: address,
                            send: '',
                            pkg_path: Config.REALM_PATH,
                            func: 'EndAuction',
                            args: [`${id}`],
                        },
                    },
                ],
                2000000
            );

            toast({
                title: 'Auction Ended',
                description: 'The auction has been ended successfully!',
                status: 'success',
                duration: 5000,
                isClosable: true,
            });
        } catch (error) {
            console.error('Error ending auction:', error);
            toast({
                title: 'Error',
                description: 'There was an error ending the auction.',
                status: 'error',
                duration: 5000,
                isClosable: true,
            });
        }
    };

    useEffect(() => {
        fetchAuctionDetails();
    }, []);

    if (!auction) {
        return <Text>Loading auction details...</Text>;
    }

    return (
        <Box borderWidth="1px" borderRadius="lg" overflow="hidden" p={4} mb={4} maxW="600px" mx="auto">
            <Text fontSize="3xl" mb={4}>{auction.title}</Text>
            <Box borderWidth="1px" borderRadius="lg" overflow="hidden" mb={4} width="100%" height="300px">
                <Image src={auction.img || 'https://via.placeholder.com/300'} alt='Auction Image' width='100%' height='100%' objectFit='cover' />
            </Box>
            <Text>Description: {auction.description}</Text>
            <Text>Start Time: {new Date(auction.begin * 1000).toLocaleString()}</Text>
            <Text>End Time: {new Date(auction.deadline * 1000).toLocaleString()}</Text>
            <Text>Starting Price: {auction.firstPrice / 1_000_000} GNOT</Text>
            <Text>Number of Bids: {auction.bids}</Text>
            <Box mt={6}>
                <Input
                    placeholder="Enter your bid (in GNOT)"
                    value={bidAmount}
                    onChange={(e) => setBidAmount(Number(e.target.value))}
                    type="number"
                />
                <Button onClick={handleBid} colorScheme="blue" mt={4}>
                    Place Bid
                </Button>
                {address === auction.owner && (
                    <Button onClick={handleEndAuction} colorScheme="red" mt={4}>
                        End Auction
                    </Button>
                )}
            </Box>
        </Box>
    );
};

export default AuctionDetails;