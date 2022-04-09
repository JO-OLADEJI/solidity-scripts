const { expect } = require('chai');
const { ethers } = require('hardhat');


describe('PayInvestors', () => {
  let deployer;
  let addr1;
  let addr2;
  let PayInvestorsContract;
  const liquidity = ethers.utils.parseEther('0.003');
  beforeEach(async () => {
    [deployer, addr1, addr2] = await ethers.getSigners();
    const payInvestors = await ethers.getContractFactory('PayInvestors');
    PayInvestorsContract = await payInvestors.deploy({ 'value': liquidity });
  });


  describe('Constructor', () => {

    it('should assign deployer as bankAdmin', async () => {
      const admin = await PayInvestorsContract.bankAdmin();
      expect(admin).to.equal(deployer['address']);
    });

    it('should have a balance equal to the liqidity sent at deployment', async () => {
      const balance = await ethers.provider.getBalance(PayInvestorsContract['address']);
      expect(balance).to.equal(liquidity);
    });

  });


  describe('Functions', () => {

    it('should return the number of investors when checkInvestors() is called', async () => {
      const investorsCount = await PayInvestorsContract.checkInvestors();
      expect(investorsCount).to.equal(0);
    });

    it('should revert when allotInvestorPay() is called by a non-admin address', async () => {
      await expect(
        PayInvestorsContract.connect(addr1).allotInvestorPay(addr2['wallet'], ethers.utils.parseEther('0.001'))
      ).to.be.reverted;
    });

    it('should allot investment to specified address when allotInvestorPay() is called by admin', async () => {
      const amount = ethers.utils.parseEther('0.001');
      await PayInvestorsContract.allotInvestorPay(addr1['address'], amount);
      expect(await PayInvestorsContract.checkInvestors()).to.equal(1);
      expect(await PayInvestorsContract.getShare(addr1['address'])).to.equal(amount);
    });

    it('should revert when amount alloted by admin is greater than the unalloted liquidity', async () => {
      const amount = ethers.utils.parseEther('0.004');
      await expect(
        PayInvestorsContract.allotInvestorPay(addr1['address'], amount)
      ).to.be.revertedWith('insufficient amount remaining');
    });

    

    it('should revert when payout() is called by a non-admin address', async () => {
      await expect(
        PayInvestorsContract.connect(addr1).payout()
      ).to.be.reverted;
    });

    it('should transfer alloted liquidity to investors addresses when payout() is called by admin', async () => {
      const amount = ethers.utils.parseEther('0.001');
      const addr1Balance = await ethers.provider.getBalance(addr1['address']);
      const addr2Balance = await ethers.provider.getBalance(addr2['address']);

      await PayInvestorsContract.allotInvestorPay(addr1['address'], amount);
      await PayInvestorsContract.allotInvestorPay(addr2['address'], amount);
      await PayInvestorsContract.payout();

      expect(await ethers.provider.getBalance(addr1['address'])).to.equal(addr1Balance.add(amount));
      expect(await ethers.provider.getBalance(addr2['address'])).to.equal(addr2Balance.add(amount));
    });

  });

});