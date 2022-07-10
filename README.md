# Alfred - Self-repaying loans for your favourite dapps

## Inspiration

The most inmportant and established dapps seem to not offer self repaying loans. It is a feature I find of extreme interest as it removes the pain point of regularly swapping the yield on my collateral and possibly the rewards granted for using the protocol to the principals asset to the repay my loan.

## What it does

Users can create _Vaults_ through which they are able to supply collateral to any Aave v2/v3 fork as well as any Compound fork.
Each _Vault_ allows for only one loan to be active at any time.

By design, each vault accrues its collateral as explained in the docs of the supported protocols. This yield is regularly swapped for the principal's asset at the best rate by leveraging 1inch's pathfinder API (called through custom oracles or Chainlink's Any API system) and used to repay a portion of the loan.
This project is a proof of concept and although contracts leveraging Chainlink are written, and should correctly behave, they are not yet officially supported.

## How we built it



## Challenges we ran into

Designing the inner workings of such a protocol has been quite the challenge and I had to review and redesign it a few times before getting there.

Not being able to query for Forex data on testnet has forced me to figure out how to fork mainnet locally.

## Accomplishments we are proud of

I am quite proud of having built this protocol by myself in a few days. It has been fun to imagine and release something that - albeit only on the surface and with an exetremely set of features - does what DAI can do.

## What we learned

While developing DEMU I learned more about EIP2612's specifications as well as became more confortable in using frontend libraries of the likes of wagmi and ethers.

## What's next for DEMU

- Allowing for additional collaterals
- Allowing for yield bearing assets to be used as collateral
- Implement self-repaying loans
- Allow for repaying the loan directly by using the collateral
- Implement folding capabilities in order to multiply exposure to an asset
- Implement whitelistsing for liquidation calls in order to avoid MEV attacks
- Release a NFT collection giving access to governance (hence becoming a DAO), revenue sharing and liquidations.
- Possibly expand the variety of stablecoins to other widely used currencies
- In the far future list DEMU on centralized and decentralized exchanges
