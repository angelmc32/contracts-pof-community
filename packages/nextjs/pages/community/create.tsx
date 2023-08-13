import { useEffect, useState } from "react";
import { EthersAdapter, SafeAccountConfig, SafeFactory } from "@safe-global/protocol-kit";
import { ethers } from "ethers";
import { useAccount } from "wagmi";

const Create = () => {
  const [safeSdk, setSafeSdk] = useState<any>(null);
  const [hasLoaded, setHasLoaded] = useState(false);
  const [ethereumObj, setEthereumObj] = useState<any>(null);
  const { address, isConnected } = useAccount();
  // const provider = useEthersProvider({ chainId: 5 });

  useEffect(() => {
    if (!hasLoaded) {
      setHasLoaded(true);
      setEthereumObj((window as any).ethereum);
    }
  }, [hasLoaded]);

  const createCommunityWallet = async () => {
    if (!address) return;

    const provider = new ethers.providers.Web3Provider(ethereumObj);
    const accounts = await ethereumObj.request({
      method: "eth_requestAccounts",
    });
    console.log(accounts);

    const safeOwner = provider.getSigner(accounts[0]);
    console.log(safeOwner);

    try {
      const ethAdapter = new EthersAdapter({
        ethers,
        signerOrProvider: safeOwner,
      });
      console.log(ethAdapter.getSigner());
      console.log(ethAdapter);
      const safeAccountConfig: SafeAccountConfig = {
        owners: [address, "0x752c9459Bb3A76caFF270bbe7b8e20A71A67648A"],
        threshold: 1,
      };
      const safeFactory = await SafeFactory.create({ ethAdapter, isL1SafeMasterCopy: true });

      console.log(safeFactory);
      safeFactory.getAddress();
      const proxyAddress = safeFactory.getAddress();
      console.log(proxyAddress);
      console.log(await provider.getCode(proxyAddress));

      const saltNonce = ethers.utils.hashMessage(safeAccountConfig.owners[0] + `${Date.now()}`);

      const _safeSdk = await safeFactory.deploySafe({
        safeAccountConfig,
        saltNonce,
        options: { gasLimit: 300000 },
      });
      console.log(_safeSdk);

      setSafeSdk(_safeSdk);

      const newSafeAddress = await _safeSdk.getAddress();
      console.log(newSafeAddress);
    } catch (error) {
      console.error(error);
    }
  };

  const logSdkObj = () => console.log(safeSdk);

  return (
    <div className="w-full h-full flex flex-col items-center mt-12">
      <h1 className="text-3xl font-medium">Create Community</h1>
      <div className="flex gap-x-4">
        <button className="btn btn-sm rounded-md" onClick={logSdkObj}>
          Log SDK obj
        </button>
        {isConnected && (
          <button className="btn btn-sm rounded-md" onClick={createCommunityWallet}>
            Create Wallet
          </button>
        )}
      </div>
    </div>
  );
};

export default Create;
