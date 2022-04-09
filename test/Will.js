const { expect } = require('chai');
const { ethers } = require('hardhat');


describe('Will', () => {
  let deployer;
  let addr1;
  let WillContract;
  const fortune = ethers.utils.parseEther('0.003');
  beforeEach(async () => {
    [deployer, addr1] = await ethers.getSigners();
    const will = await ethers.getContractFactory('Will');
    WillContract = await will.deploy({ 'value': fortune });
  });


  describe('Constructor', () => {
    it('should set the deployer as the contract owner', async () => {
      const contractOwner = await WillContract.owner();
      expect(deployer['address']).to.equal(contractOwner);
    });
  
    it('should set fortune of the contract to the value of ether sent at deployment', async () => {
      const contractFortune = await WillContract.fortune();
      expect(contractFortune.toString()).to.equal(fortune.toString());
    });
  
    it('should set the deceased state to false', async () => {
      const isDeceased = await WillContract.isDeceased();
      expect(isDeceased).to.equal(false);
    });
  });


  describe('Functions', () => {
    
    it('should set inheritance value when the setInheritanceForAddress() is called by contract owner', async () => {
      const amount = ethers.utils.parseEther('0.001');
      await WillContract.setInheritanceForAddress(addr1['address'], amount);
      const addr1InheritanceValue = await WillContract.getInheritance(addr1['address']);
      expect(addr1InheritanceValue.toString()).to.equal(amount.toString());
    });
    
    it('should revert when setInheritanceForAddress() is called by an address other than owner', async () => {
      const amount = ethers.utils.parseEther('0.001');
      await expect(
        WillContract.connect(addr1).setInheritanceForAddress(addr1, amount)
      ).to.be.reverted;
    });

    it('should revert when hadDeceased() is called by an address other than owner', async () => {
      await expect(
        WillContract.connect(addr1).hadDeceased()
      ).to.be.reverted;
    });

    it('should disburse inheritance to assigned addresses when hasDeceased() is called by owner', async () => {
      const addr1Balance = await ethers.provider.getBalance(addr1['address']);
      const amount = ethers.utils.parseEther('0.001');
      await WillContract.setInheritanceForAddress(addr1['address'], amount);
      await WillContract.hadDeceased();
      expect(await ethers.provider.getBalance(addr1['address'])).to.equal(amount.add(addr1Balance));
    });

  });

});