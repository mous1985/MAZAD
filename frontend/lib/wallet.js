import { Wallet } from '@gnolang/tm2-js-client';


export async function createWallet(mnemonic) {
  try {
    const wallet = await Wallet.fromMnemonic(mnemonic);
    console.log("Wallet created:", wallet);
    return wallet;
  } catch (error) {
    console.error("Error creating wallet:", error);
    throw error;
  }
}


export async function getBalance(wallet) {
  try {
    const balance = await wallet.getBalance();
    return balance;
  } catch (error) {
    console.error("Error fetching balance:", error);
    throw error;
  }
}
