// import { JSONRPCProvider } from '@gnolang/tm2-js-client';

// // Crée une instance du provider JSON-RPC pour communiquer avec le noeud Gno
// const provider = new JSONRPCProvider('http://staging.gno.land:36657');

// // Fonction pour récupérer les informations de bloc comme exemple
// export async function getBlockInfo(blockHeight: number) {
//   try {
//     const block = await provider.getBlock(blockHeight);
//     return block;
//   } catch (error) {
//     console.error('Erreur lors de la récupération des informations de bloc :', error);
//     throw error;
//   }
// }

// // Fonction pour envoyer une transaction signée
// export async function sendTransaction(signedTx: string, endpoint: 'broadcast_tx_sync' | 'broadcast_tx_commit') {
//     try {
//       // Ajout du second argument pour spécifier le type d'envoi (par exemple "broadcast_tx_commit")
//       const result = await provider.sendTransaction(signedTx, endpoint);
//       return result;
//     } catch (error) {
//       console.error('Erreur lors de l\'envoi de la transaction :', error);
//       throw error;
//     }
//   }
// // Fonction pour interagir avec un realm (exemple de rendu)
// export async function getRealmRenderOutput(packagePath: string, path: string) {
//   try {
//     const result = await provider.getRenderOutput(packagePath, path);
//     return result;
//   } catch (error) {
//     console.error('Erreur lors de la récupération du rendu du realm :', error);
//     throw error;
//   }
// }
import { JSONRPCProvider } from '@gnolang/tm2-js-client';

const provider = new JSONRPCProvider(import.meta.env.VITE_CHAIN_RPC);

// Fonction pour interagir avec le smart contract
export async function callRenderMethod(packagePath: string, path: string) {
  try {
    const result = await provider.getRenderOutput(packagePath, path);
    return result;
  } catch (error) {
    console.error('Erreur lors de la récupération des enchères :', error);
    throw error;
  }
}

// Fonction pour envoyer une transaction
export async function sendTransaction(signedTx: string) {
  try {
    const result = await provider.sendTransaction(signedTx, 'commit');
    return result;
  } catch (error) {
    console.error('Erreur lors de l\'envoi de la transaction :', error);
    throw error;
  }
}
