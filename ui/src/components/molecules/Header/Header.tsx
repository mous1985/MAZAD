// src/components/molecules/Header/Header.tsx
import { useContext } from 'react';
import { Flex, Box, Text } from '@chakra-ui/react';
import { Link } from 'react-router-dom';
import { CheckCircleIcon } from '@chakra-ui/icons';
import Connect from '../../atoms/Connect/Connect';
import AccountContext from '../../../context/AccountContext.ts';

const Header = () => {
  const { address } = useContext(AccountContext);

  return (
    <Flex
      as="header"
      width="100%"
      height="80px"
      padding="0 16px"
      alignItems="center"
      justifyContent="space-between"
      bg="mazad.secondary"
      color="white"
      boxShadow="md"
      position="fixed"
      top="0"
      left="0"
      zIndex="1000"
    >
      <Box display="flex" alignItems="center">
        <Link to="/">
          <Text fontSize="xl" fontWeight="bold">
            MAZAD
          </Text>
        </Link>
      </Box>
      <Box display="flex" alignItems="center">
        {!address ? (
          <Connect />
        ) : (
          <Box display="flex" alignItems="center">
            <CheckCircleIcon color="green.500" mr={2} />
            <Text>CONNECTED</Text>
          </Box>
        )}
      </Box>
    </Flex>
  );
};

export default Header;