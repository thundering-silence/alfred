const { ethers } = require("ethers");
const fetch = require("node-fetch");
require("dotenv").config();

const provider = ethers.getDefaultProvider("http://localhost:8545");

const dataRequester = new ethers.Contract(
  process.env.SWAP_DATA_REQUESTER,
  [
    "event APIRequest(string endpoint,string path,address callbackAddress,bytes4 callbackFuncSelector)",
  ],
  provider
);

dataRequester.on(
  "APIRequest",
  async (endpoint, path, callbackAddress, callbackFuncSelector) => {
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

    // workaround to use the 1inch API and still get a OK response
    const editedEndpoint = endpoint.replace(
      `fromAddress=${callbackAddress}`,
      process.env.FROM_ADDRESS_OVERRIDE
    );

    const res = await fetch(editedEndpoint);
    const data = await res.json();

    if (!data.tx && data?.statusCode != 200) {
      console.error(data);
      return;
    }
    const attrs = path.split(",");
    const value = attrs.reduce((acc, current) => acc[current], data);
    try {
      const vault = new ethers.Contract(
        callbackAddress,
        ["function executeSwap(bytes memory data) public"],
        wallet
      );
      const tx = await vault.executeSwap(value);
      const receipt = await tx.wait();
    } catch (e) {
      console.error(e);
    }
  }
);
