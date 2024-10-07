// src/pages/CreateAuctionPage.tsx
import { Box, Heading } from '@chakra-ui/react';
import CreateAuction from '../components/atoms/Auction/CreateAuction';
import { useNavigate } from 'react-router-dom';

const CreateAuctionPage = () => {
    const navigate = useNavigate();

    // Function called after a successful auction creation to navigate to another page
    const handleAuctionCreated = () => {
        navigate('/'); // Redirect to the home page or another appropriate page
    };

    return (
        <Box maxW="xl" mx="auto" mt={10} p={6}>
            <Heading as="h2" mb={6}>Create a New Auction</Heading>
            <CreateAuction onAuctionCreated={handleAuctionCreated} />
        </Box>
    );
};

export default CreateAuctionPage;