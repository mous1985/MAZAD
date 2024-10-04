const { VITE_CHAIN_ID, VITE_CHAIN_RPC, VITE_REALM_PATH } = import.meta.env;

if (!VITE_CHAIN_ID || !VITE_CHAIN_RPC || !VITE_REALM_PATH) {
  throw new Error('Missing environment variables');
}

export default {
  CHAIN_ID: VITE_CHAIN_ID,
  CHAIN_RPC: VITE_CHAIN_RPC,
  REALM_PATH: VITE_REALM_PATH,
};
