
import { WagmiConfig } from 'wagmi'

import { Route } from "wouter";

import './App.css'
import Footer from "./components/Footer/Footer";
import Nav from "./components/Nav/Nav";
import Home from "./pages/Home/Home";
import Vaults from "./pages/Vaults/Vaults";

import client from './web3/wagmi.config';

function App() {
  return (
    <WagmiConfig client={client}>
      <Nav />
      <main>
        <Route path="/">
          <Home />
        </Route>
        <Route path="/vaults">
          <Vaults />
        </Route>
      </main>
      <Footer />
    </WagmiConfig>
  )
}

export default App
