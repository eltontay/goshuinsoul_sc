import '@nomicfoundation/hardhat-toolbox';
import 'hardhat-abi-exporter';
import 'hardhat-deploy';
import 'hardhat-log-remover';
import './tasks/library/opensea-proxy-address';
import { HardhatUserConfig } from 'hardhat/config';
import { NetworksUserConfig } from 'hardhat/types';
import jsonConfig from './.secrets/config.json';
import './tasks/library/graph-config';

type IpfsNodeType = Record<
  string,
  {
    headers: Record<string, string>;
    url: string;
    gateway: string;
  }
>;

const { namedAccounts } = jsonConfig;
const networks = jsonConfig.networks as NetworksUserConfig;
const ipfsNodeConfig = jsonConfig.ipfsNodeConfig as IpfsNodeType;

const abiExporter: any = {
  path: './abi',
  runOnCompile: true,
  clear: true,
  flat: true,
  spacing: 2,
};

const config: HardhatUserConfig = {
  abiExporter,
  solidity: {
    version: '0.8.16',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      evmVersion: 'istanbul',
    },
  },
  namedAccounts,
  networks,
};

// If you want to pin your NFT assets, add a token here from https://nft.storage
export const nftStorageToken = '';

export default config;

export const ipfsNodes: IpfsNodeType = ipfsNodeConfig;
