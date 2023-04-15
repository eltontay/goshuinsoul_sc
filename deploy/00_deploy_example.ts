import { getChainId } from 'hardhat';
import { DeployFunction } from 'hardhat-deploy/types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

// If you have more than one IPFS node, use the key from the default.hardhat.config.ts file to choose which one to use.
const preferredIpfsNode: string | undefined = undefined;

const migrate: DeployFunction = async ({
  getNamedAccounts,
  run,
  deployments: { deploy },
  config,
  network,
}: HardhatRuntimeEnvironment) => {
  const { deployer } = await getNamedAccounts();
  if (!deployer) {
    console.error(
      '\n\nERROR!\n\nThe node you are deploying to does not have access to a private key to sign this transaction. Add a Private Key in this application to solve this.\n\n'
    );
    process.exit(1);
  }

  const proxyRegistryAddress = await run('opensea-proxy-address', {
    chainid: await getChainId(),
  });

  const collectionName = 'SoulboundToken';
  const collectionSymbol = 'NFT';

  await deploy('SoulboundToken', {
    from: deployer,
    args: [
      "Goushuin",
      "GSOUL",
      'ipfs://QmXiwK9nn4ufrS4fojftqpaFCrKiFrNkxNrr3AbvbsHV2X/', // TODO: dynamic
      // proxyRegistryAddress,
      // deployer,
    ],
    log: true,
  });
  let hasEtherScanInstance = false;
  try {
    await run('verify:get-etherscan-endpoint');
    hasEtherScanInstance = true;
  } catch (e) {
    // ignore
  }
  if (hasEtherScanInstance) {
    await run('sourcify');
    if (!config.verify?.etherscan?.apiKey) {
      console.error(
        `\n\nERROR!\n\nYou have not set your Etherscan API key in your hardhat.config.ts file. Set it and run\n\npnpm hardhat --network '${network.name}' etherscan-verify\n\n`
      );
    } else {
      await new Promise((resolve) => {
        setTimeout(resolve, 10 * 1000);
      }); // allow etherscan to catch up
      await run('etherscan-verify');
    }
  }

  return true;
};

export default migrate;

migrate.id = '00_deploy_advancedERC721';
migrate.tags = ['advancedERC721'];
