const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('SimpleStorage', () => {
  let SimpleStorageContract;
  beforeEach(async () => {
    const [deployer] = await ethers.getSigners();
    const simpleStorage = await ethers.getContractFactory('Storage');
    SimpleStorageContract = await simpleStorage.deploy();
  });

  it('should store the default value 0 for number variable when contract is deployed', async () => {
    const number = await SimpleStorageContract.retrieve();
    expect(number.toString()).to.equal('0');
  });

  it('should overwrite the number variable when store() is called', async () => {
    const data = 15;
    await SimpleStorageContract.store(15);
    const number = await SimpleStorageContract.retrieve();
    expect(number.toString()).to.equal(data.toString());
  });

});