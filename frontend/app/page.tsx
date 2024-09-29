// "use client";

// import { useEffect, useState } from 'react';
// import { AdenaService } from '../utils/adena';
// import { IAccountInfo } from '../utils/adena.types';

// export default function Home() {
//   const [account, setAccount] = useState<IAccountInfo | null>(null);
//   const [isLoading, setIsLoading] = useState(true);

//   useEffect(() => {
//     const connectToAdena = async () => {
//       try {
//         // Connexion à Adena Wallet
//         await AdenaService.establishConnection('Mazad');
//         const accountInfo = await AdenaService.getAccountInfo();
//         setAccount(accountInfo);
//       } catch (error) {
//         console.error('Erreur lors de la connexion à Adena Wallet :', error);
//       } finally {
//         setIsLoading(false);
//       }
//     };

//     connectToAdena();
//   }, []);

//   return (
//     <div>
//       <h1>Bienvenue sur Mazad</h1>
//       {isLoading ? (
//         <p>Connexion à Adena Wallet...</p>
//       ) : account ? (
//         <div>
//           <p>Connecté en tant que : {account.address}</p>
//           <p>Solde : {account.coins}</p>
//         </div>
//       ) : (
//         <p>Impossible de se connecter à Adena Wallet. Veuillez vérifier l'installation.</p>
//       )}
//     </div>
//   );
// }
// frontend/app/page.tsx

"use client";

//import { useEffect, useState } from 'react';
import {  useState } from 'react';
import { AdenaService } from '../utils/adena';
//import { IAccountInfo } from '../utils/adena.types';

export default function Home() {
  const [isConnected, setIsConnected] = useState(false);
 // const [account, setAccount] = useState<IAccountInfo | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const connectToAdena = async () => {
    setIsLoading(true);
    setError(null);
    try {
      // Connexion à Adena Wallet
      await AdenaService.establishConnection('Mazad');
      //const accountInfo = await AdenaService.getAccountInfo();
      await AdenaService.getAccountInfo();
      setIsConnected(true);
    } catch (err: any) {
      console.error('Erreur lors de la connexion à Adena Wallet :', err);
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      <h1>Bienvenue sur Mazad</h1>
      {isConnected ? (
        <p>Connexion réussie</p>
      ) : (
        <div>
          <button onClick={connectToAdena} disabled={isLoading}>
            {isLoading ? 'Connexion...' : 'Connecter avec Adena Wallet'}
          </button>
          {error && <p style={{ color: 'red' }}>Erreur : {error}</p>}
        </div>
      )}
    </div>
  );
}
