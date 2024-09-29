import { GnoProvider } from "@gnolang/gno-js-client";

const provider = new GnoProvider("https://test3.gno.land");

// Fonction pour envoyer une transaction
export async function sendTransaction(sender, receiver, amount) {
  const tx = {
    sender: sender,
    recipient: receiver,
    amount: amount,
  };
  return await provider.broadcastTxCommit(tx);
}

// Fonction pour obtenir la liste des enchères
export async function getAuctions() {
  const result = await provider.query('/auctions');
  return result.data;
}
