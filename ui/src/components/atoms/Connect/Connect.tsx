import { useState, useContext } from 'react';
import { Button, Spinner, Box, useToast } from '@chakra-ui/react';  
import ProviderContext from '../../../context/ProviderContext.ts';
import AccountContext from '../../../context/AccountContext.ts';
import { AdenaService } from '../../../services/adena/adena.ts';
import Config from '../../../config.ts';
import Adena from '../../../shared/assets/img/adena.svg';

const Connect = () => {
  const { provider } = useContext(ProviderContext);
  const { setChainID, setAddress } = useContext(AccountContext);
  const [isLoading, setIsLoading] = useState(false);
  const toast = useToast();

  const handleWalletConnect = async () => {
    setIsLoading(true);

    try {
      await AdenaService.establishConnection('mazad');
      const accountInfo = await AdenaService.getAccountInfo();
      await AdenaService.switchNetwork(Config.CHAIN_ID);
      
      setAddress(accountInfo.address);
      setChainID(Config.CHAIN_ID);

      toast({
        title: 'Successfully connected to Adena',
        status: 'success',
        duration: 4000,
        isClosable: true,
        position: 'bottom-right',
      });

      if (provider) {
        const response = await provider.evaluateExpression(
          Config.REALM_PATH,
          `GetAuctions()`
        );
        console.log('Auction data:', response);
      }

    } catch (error) {
      console.error(error);
      toast({
        title: 'Unable to connect to Adena',
        status: 'error',
        duration: 4000,
        isClosable: true,
        position: 'bottom-right',
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Box textAlign="center" mt="20px">
      <Button
        onClick={handleWalletConnect}
        variant="buttonPrimary"  
        isLoading={isLoading}
        loadingText="CONNECTING"
        leftIcon={!isLoading ? <img src={Adena} alt="Adena Icon" style={{ width: '20px', height: 'auto' }} />: undefined} 
      >
        {isLoading ? "CONNECTING" : "CONNECT WALLET"}
      </Button>
    </Box>
  );
};

export default Connect;

