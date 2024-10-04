# Mazad - A Decentralized Auction Platform

Mazad is a decentralized auction platform built using `React`, `TypeScript`, and `Chakra UI` for the frontend, and [Gno](https://github.com/gnolang/gno) language for the backend. It allows users to create auctions and place bids, with all actions managed through Gno smart contracts and the Adena Wallet.

## Prerequisites

- Node.js (v18.20.3 or later)
- npm
- Go 1.21+
- Adena Wallet

## Features

- **Create Auctions**: Users can create auctions specifying details such as the title, description, starting price, and duration.
- **Place Bids**: Once an auction is active, users can place bids directly from the frontend.
- **Wallet Integration**: Mazad uses the Adena Wallet to sign transactions and manage user accounts.

## Run Mazad Locally

Mazad consists of a React frontend, and a Gno backend (smart contracts). The frontend and backend code can be found at `mazad/ui/` and `mazad/api/` respectively.

### 1. Clone the Mazad Repository

```bash
git clone git@github.com:YourUsername/mazad.git

```

#### 2. Set up environment variables

Create a `.env` file in the `ui/` folder following the template found in
`.env.example`.

To do this, your `.env` file should contain the following:

```bash
VITE_CHAIN_ID=<gno-chain-id>
VITE_CHAIN_RPC=wss://<gno-chain-rpc>/websocket
VITE_REALM_PATH=<onchain-path-to-mazad>

```

### 4. Set up a local development node with `gnodev`

`gnodev` is a tool that allows you to run a local Gno.land node effortlessly.
To get started, install `gnodev`. To do this, clone the Gno monorepo:

```bash
git clone git@github.com:gnolang/gno.git 
```

From the root of the Gno repo, install the all the necessary binaries and
tools following the next steps:

1. Install the `gno` & `gnodev` binaries with the following command in the root of the cloned monorepo:

```bash
make install
```

2. Run the `gnodev` binary in the mazad repo, giving it paths
to the package and realm:

```bash
gnodev ./api/p/auction ./api/r/auction
```

Running this command will spin up a local node that the mazad UI
will be able to connect to.

Make sure that the chain RPC endpoint that `gnodev` is running on matches the one
in the `.env` file.

#### 3. Start the frontend with `vite`

Navigate to the `ui/` folder and install the dependencies:

```bash
cd ui
npm install
```

Once the dependencies are installed, you can run the development server:

```bash
npm run dev
```

#### 5.Contribution

We welcome contributions! Feel free to submit a pull request or open an issue on GitHub.
