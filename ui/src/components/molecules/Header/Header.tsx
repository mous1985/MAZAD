import { FC, useContext } from 'react';
import { Flex, Button, Box, Text } from '@chakra-ui/react'; // Utilisation de Chakra pour le style
import Connect from '../../atoms/Connect/Connect.tsx';
import AccountContext from '../../../context/AccountContext.ts';

const Header: FC = () => {
  const { address } = useContext(AccountContext); // Récupération de l'adresse depuis le contexte

  return (
    <Flex
      as="header"
      bg="gray.300"
      h="20"
      p="8"
      align="center"
      justify="center"
      w="100vw"
    >
      {address ? (
        <Box bg="green.600" p="2" rounded="md">
          <Text color="white">Connected: {address}</Text> {/* Affiche l'adresse connectée */}
        </Box>
      ) : (
        <Button colorScheme="teal" onClick={() => <Connect />}>
          Connect to Adena Wallet
        </Button> /* Bouton pour connecter le portefeuille */
      )}
    </Flex>
  );
};

export default Header;
