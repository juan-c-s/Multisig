import React from 'react';
import { useEffect, useState } from "react";

import logo from './logo.svg';
import './App.css';
import { Wallet } from "fuels";
// Import the contract factory -- you can find the name in index.ts.
// You can also do command + space and the compiler will suggest the correct name.
import { MultisigAbi__factory } from "./contracts";

// The address of the contract deployed the Fuel testnet
const CONTRACT_ID =
  "0x9f8f75696bc11e899afd363609515bd037d5820ccc118aaf012ea68cf3dbb2ec";

//the private key from createWallet.js
const WALLET_SECRET =
  "0xde97d8624a438121b86a1956544bd72ed68cd69f2c99555b08b1e8c51ffd511c";

const TOKEN_CONTRACT_ID = "";


// Create a Wallet from given secretKey in this case
// The one we configured at the chainConfig.json
const wallet = Wallet.fromPrivateKey(
  WALLET_SECRET,
  // "https://beta-3.fuel.network/graphql"
);

// Connects out Contract instance to the deployed contract
// address using the given wallet.
const contract = MultisigAbi__factory.connect(CONTRACT_ID, wallet);

// const tokenContract = 
const init = async () => {
  const { value } = await contract.functions.get_threshold().get();
  // console.log(value.toNumber());
  console.log(value.toNumber());
  await contract.functions.constructor(3).txParams({ gasPrice: 1 }).call();
}

function App() {
  useEffect(() => {
    async function main() {
      const { value } = await contract.functions.get_threshold().get();
      console.log(value.toNumber());
      // const {val} = await contract.functions.get_threshold().get();
    }
    main();
  }, []);
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.tsx</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
