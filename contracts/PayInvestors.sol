// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**
 * @title PayInvestors
 * @dev contract to allot shares to investors and allow payout
 */
contract PayInvestors {

    uint public liquidity;
    uint public alloted;
    address immutable public bankAdmin;
    address payable[] investorWallets;
    mapping(address => uint) public investorsShare;

    /**
     * @dev make contract deployer the bank admin
     * @dev make entire liquidity equal to amount sent to contract onDeployment
     */
    constructor() payable {
        bankAdmin = msg.sender;
        liquidity = msg.value;
    }

    /**
     * @dev modifier to allow only contract deployer perform an operation
     */
    modifier onlyAdmin {
        require(msg.sender == bankAdmin);
        _;
    }

    /**
     * @dev checks for how many investors have shares in the contract
     * @return number of investors
     */
    function checkInvestors() public view returns (uint) {
        return investorWallets.length;
    }


    /**
     * @dev allot shares, out of the total liquidity, to investors
     * @param wallet wallet address of investor
     * @param amount amount to allot to provided address
     */
    function allotInvestorPay(address payable wallet, uint amount) public onlyAdmin {
        require(alloted + amount <= liquidity, "insufficient amount remaining");
        investorWallets.push(wallet);
        investorsShare[wallet] = amount;
        alloted += amount;
    }


    /**
     * @dev payout shares to investors
     */
    function payout() external payable onlyAdmin {
        address payable[] memory payRoll = investorWallets;

        for(uint i = 0; i < payRoll.length; ++i) {
            uint share = investorsShare[investorWallets[i]];
            investorWallets[i].transfer(share);
            liquidity -= share;
        }
    }


    function getShare(address wallet) external view returns(uint256) {
        return investorsShare[wallet];
    }

}
