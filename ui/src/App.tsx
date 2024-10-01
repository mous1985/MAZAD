import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import { ChakraProvider } from '@chakra-ui/react';
import './App.css';
import { useState } from 'react';
import { GnoWSProvider } from '@gnolang/gno-js-client';
import Config from './config';
import AccountContext from './context/AccountContext';
import ProviderContext from './context/ProviderContext';
import Home from './components/organisms/Home/Home';
import theme from './theme/theme';
import AuctionDetails from './components/organisms/AuctionDetails/AuctionDetails';

const App = () => {
  // Manage the state of GnoJS provider (WebSocket Provider)
  const [provider, setProvider] = useState<GnoWSProvider | null>(
    new GnoWSProvider(Config.CHAIN_RPC)
  );

  // Manage the state of user account (address and chainID)
  const [address, setAddress] = useState<string | null>(null);
  const [chainID, setChainID] = useState<string | null>(Config.CHAIN_ID);

  // Prepare values to pass to contexts
  const accountContextValue = {
    address,
    chainID,
    setAddress,
    setChainID,
  };

  const providerContextValue = {
    provider,
    setProvider,
  };

  return (
    <ProviderContext.Provider value={providerContextValue}>
      <AccountContext.Provider value={accountContextValue}>
        {/* Use ChakraProvider here to apply global theme */}
        <ChakraProvider theme={theme}>
          <Router>
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/auction/:id" element={<AuctionDetails />} />  {/* Route pour la page d'enchères */}
            </Routes>
          </Router>
        </ChakraProvider>
      </AccountContext.Provider>
    </ProviderContext.Provider>
  );
};

export default App;

