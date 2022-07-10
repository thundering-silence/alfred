import { BigNumber, ethers, utils } from "ethers";

export const aTokensV3 = [
  {
    pool: import.meta.env.V_AAVE_V3_POOL,
    underlying: import.meta.env.V_WMATIC,
    symbol: "WMATIC",
    address: "0x6d80113e533a2C0fe82EaBD35f1875DcEA89Ea97",
  },
];
export const vTokensV3 = [
  {
    pool: import.meta.env.V_AAVE_V3_POOL,
    underlying: import.meta.env.V_MATIC,
    symbol: "MATIC",
    address: import.meta.env.V_AAVE_V3_vWMATIC,
  },
  {
    pool: import.meta.env.V_AAVE_V3_POOL,
    underlying: import.meta.env.V_DAI,
    symbol: "DAI",
    address: "0x8619d80FB0141ba7F184CbF22fd724116D9f7ffC",
  },
];

export const aTokensV2 = [
  {
    pool: import.meta.env.V_AAVE_V2_POOL,
    underlying: import.meta.env.V_WMATIC,
    symbol: "WMATIC",
    address: "0x8dF3aad3a84da6b69A4DA8aeC3eA40d9091B2Ac4",
  },
];

export const vTokensV2 = [
  {
    pool: import.meta.env.V_AAVE_V2_POOL,
    underlying: import.meta.env.V_MATIC,
    symbol: "MATIC",
    address: import.meta.env.V_AAVE_V2_vWMATIC,
  },
  {
    pool: import.meta.env.V_AAVE_V2_POOL,
    underlying: import.meta.env.V_DAI,
    symbol: "DAI",
    address: "0x75c4d1Fb84429023170086f06E682DcbBF537b7d",
  },
];

export const getProtocol = (address) => {
  const data = {
    [`${import.meta.env.V_AAVE_V2_POOL}`]: "Aave V2",
    [`${import.meta.env.V_AAVE_V3_POOL}`]: "Aave V3",
  };
  return data[address];
};

export const getAssetsBalances = async (vaultAddress, signer, assets) => {
  const result = await Promise.all(
    assets.map(async (current) => {
      const token = new ethers.Contract(
        current.address,
        ["function balanceOf(address src) public view returns (uint)"],
        signer
      );
      const res = await token.balanceOf(vaultAddress);
      if (!res.eq(BigNumber.from("0"))) {
        return {
          protocol: getProtocol(current.pool),
          pool: current.pool,
          underlying: current.underlying,
          symbol: current.symbol,
          balance: utils.formatEther(res),
        };
      }
    })
  );
  return result.filter((el) => !!el);
};
