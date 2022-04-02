// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract PayInvestors {

    uint public liquidity;
    address immutable bankAdmin;
    address payable[] investorWallets;
    mapping(address => uint) public investorsShare;

    constructor() payable {
        bankAdmin = msg.sender;
        liquidity = msg.value;
    }

    modifier onlyAdmin {
        require(msg.sender == bankAdmin);
        _;
    }

    function checkInvestors() public view returns (uint) {
        return investorWallets.length;
    }

    function allocateInvestorPay(address payable wallet, uint amount) public onlyAdmin {
        investorWallets.push(wallet);
        investorsShare[wallet] = amount;
    }

    function payout() external payable onlyAdmin {
        address payable[] memory payRoll = investorWallets;

        for(uint i = 0; i < payRoll.length; ++i) {
            uint share = investorsShare[investorWallets[i]];
            investorWallets[i].transfer(share);
            liquidity = liquidity - share;
        }
    }

}
