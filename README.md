# Alfred - Self-repaying loans for your favourite dapps

## Inspiration

The most important and established lending protocols seem to not offer self repaying loans. It is a feature I find of extreme interest as it removes the pain point of regularly swapping the yield on my collateral, and possibly the rewards granted for using the protocol, to the principals asset to the repay my loan.

## What it does

Users can create _Vaults_ through which they are able to supply collateral to any Aave v2/v3 fork as well as any Compound fork.
Each _Vault_ allows for only one loan to be active at any time.

By design, each vault accrues its collateral as explained in the docs of the supported protocols. This yield is regularly swapped for the principal's asset at the best rate by leveraging 1inch's pathfinder API (called through custom oracles or Chainlink's Any API system) and used to repay a portion of the loan.
This project is a proof of concept and although contracts leveraging Chainlink are written, and should correctly behave, they are not yet officially supported.

## How we built it



## Challenges we ran into

Architecturing the inner workings of such a protocol has been quite the challenge and I had to review and redesign it a few times before getting there.

Not being able to query for Forex data on testnet has forced me to figure out how to fork mainnet locally.

## Accomplishments we are proud of


## What we learned




## What's next for Alfred

- Integrate additional protocols by writing new delegates
