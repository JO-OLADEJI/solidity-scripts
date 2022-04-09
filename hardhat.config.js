require('dotenv').config();
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {

  solidity: {
    version: '0.8.0'
  },

  defaultNetwork: 'ganache',

  networks: {
    'hardhat': {},
    'ganache': {
      url: 'HTTP://127.0.0.1:7545',
      accounts: [`0x${process.env.ACCOUNT_1}`, `0x${process.env.ACCOUNT_2}`]
    }
  }

};
