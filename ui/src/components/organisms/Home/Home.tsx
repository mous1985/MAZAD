import { useState, useEffect, useContext } from 'react';
import { Box, Text } from '@chakra-ui/react';
import Config from '../../../config.ts';
import ProviderContext from '../../../context/ProviderContext.ts';
import AccountContext from '../../../context/AccountContext.ts';
import Connect from '../../atoms/Connect/Connect';
const Home = () => {
  const { address } = useContext(AccountContext); 
  const { provider } = useContext(ProviderContext);

  const test = async () => {
    if (!provider) {
      throw new Error('invalid chain RPC URL');
    }
    console.log('testing');

    const response: string = await provider.evaluateExpression(
      Config.REALM_PATH,
      `GetAuctions()`,
    );
    console.log('response:', response);
  };

  useEffect(() => {
    test();
  }, []);

  return (
    <Box textAlign="center" mt="50px">
      <Text fontSize="4xl" mb="20px">
        Welcome to Mazad
      </Text>

      {/* Check if user is connected : Display the button if not connected */}
      {!address ? (
        <Connect /> // Connect Wallet button
      ) : (
        <Text color="green.500">Connected to Adena </Text> // Display the address if connected
      )}
    </Box>
  );
};

export default Home;

