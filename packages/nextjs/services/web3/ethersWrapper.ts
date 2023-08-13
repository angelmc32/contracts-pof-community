import { EthersAdapter } from "@safe-global/protocol-kit";
import { ethers } from "ethers";

const RPC_URL = "https://eth-goerli.g.alchemy.com/v2/J4lzN7gNzQeIc4GqCSWqEDPwj8zGeLgJ";
const provider = new ethers.providers.JsonRpcProvider(RPC_URL);

const safeOwner = provider.getSigner(0);

export const ethAdapter = new EthersAdapter({
  ethers,
  signerOrProvider: safeOwner,
});
