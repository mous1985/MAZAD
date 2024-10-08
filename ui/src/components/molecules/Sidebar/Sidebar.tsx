import { useState } from 'react';
import { Box, Flex, Link, Text, VStack } from '@chakra-ui/react';
import { Link as RouterLink } from 'react-router-dom';

const Sidebar = () => {
    const [isVisible, setIsVisible] = useState(false);

    const handleMouseEnter = () => {
        setIsVisible(true);
    };

    const handleMouseLeave = () => {
        setIsVisible(false);
    };

    return (
        <>
            {/* Sidebar */}
            <Box
                bg="rgba(0, 0, 0, 0.01)"
                color="white"
                p={4}
                height="100vh"
                width={isVisible ? "250px" : "50px"}
                position="fixed"
                left={0}
                top={0}
                transition="width 0.3s, opacity 0.3s"
                overflow="hidden"
                boxShadow="lg"
                onMouseEnter={handleMouseEnter}
                onMouseLeave={handleMouseLeave}
            >
                <Flex direction="column" alignItems="flex-start" opacity={isVisible ? 1 : 0} transition="opacity 0.5s">
                    <Box mb={8}>
                        <Link as={RouterLink} to="/" fontWeight="bold" fontSize="xl" _hover={{ textDecoration: 'none', color: 'teal.300' }}>
                            Auction Platform
                        </Link>
                    </Box>
                    <VStack align="flex-start" spacing={8}>
                        <Link as={RouterLink} to="/create-auction" mt={8} _hover={{ textDecoration: 'none', color: 'teal.300', bg: 'rgba(255, 255, 255, 0.1)', borderRadius: 'md', p: 2 }}>
                            <Text>Create Auction</Text>
                        </Link>
                        <Link as={RouterLink} to="/auctions-ongoing" _hover={{ textDecoration: 'none', color: 'teal.300', bg: 'rgba(255, 255, 255, 0.1)', borderRadius: 'md', p: 2 }}>
                            <Text>Auctions Ongoing</Text>
                        </Link>
                        <Link as={RouterLink} to="/auctions-upcoming" _hover={{ textDecoration: 'none', color: 'teal.300', bg: 'rgba(255, 255, 255, 0.1)', borderRadius: 'md', p: 2 }}>
                            <Text>Auctions Upcoming</Text>
                        </Link>
                        <Link as={RouterLink} to="/auctions-closed" _hover={{ textDecoration: 'none', color: 'teal.300', bg: 'rgba(255, 255, 255, 0.1)', borderRadius: 'md', p: 2 }}>
                            <Text>Auctions Closed</Text>
                        </Link>
                    </VStack>
                </Flex>
            </Box>
        </>
    );
};

export default Sidebar;