import { useEffect, useState } from 'react';

function App() {
  const [isWalletConnected, setIsWalletConnected] = useState(false);

  useEffect(() => {
    if (window.adena) {
      window.adena.AddEstablish("MyAppName").then((res: { code: number }) => {
        if (res.code === 0) {
          setIsWalletConnected(true);
        }
      }).catch(console.error);
    } else {
      console.log("Adena Wallet not detected.");
    }
  }, []);

  return (
    <div>
      {isWalletConnected ? <p>Wallet connected</p> : <p>Connect your wallet</p>}
    </div>
  );
}

export default App;
