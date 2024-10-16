import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import { ChakraProvider, Box, Flex } from '@chakra-ui/react';
import './App.css';
import { useState } from 'react';
import { GnoWSProvider } from '@gnolang/gno-js-client';
import Config from './config';
import AccountContext from './context/AccountContext';
import ProviderContext from './context/ProviderContext';
import Home from './components/organisms/Home/Home';
import theme from './theme/theme';
import AuctionDetails from './components/organisms/AuctionDetails/AuctionDetails';
import CreateAuctionPage from './pages/CreateAuctionPage';
import Header from './components/molecules/Header/Header';
import Sidebar from './components/molecules/Sidebar/Sidebar'; // Import the Sidebar component
// import UpcomingAuctionsPage from './pages/UpcomingAuctionsPage';
// import OngoingAuctionsPage from './pages/OngoingAuctionsPage';
// import ClosedAuctionsPage from './pages/ClosedAuctionsPage';

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
        <ChakraProvider theme={theme}>
          <Router>
            <Header />
            <Flex>
              <Sidebar /> {/* Add the Sidebar component */}
              <Box as="main" className="main-content" ml={{ base: 0, md: "200px" }} p={4}>
                <Routes>
                  <Route path="/" element={<Home />} />
                  <Route path="/auction/:id" element={<AuctionDetails />} />
                  <Route path="/create-auction" element={<CreateAuctionPage />} />
                  {/* <Route path="/upcoming-auctions" element={<UpcomingAuctionsPage />} />
                  <Route path="/ongoing-auctions" element={<OngoingAuctionsPage />} />
                  <Route path="/closed-auctions" element={<ClosedAuctionsPage />} /> */}
                </Routes>
              </Box>
            </Flex>
          </Router>
        </ChakraProvider>
      </AccountContext.Provider>
    </ProviderContext.Provider>
  );
};

export default App;