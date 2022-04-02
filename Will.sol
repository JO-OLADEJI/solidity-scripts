// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Will {

    address immutable owner;
    uint fortune;
    bool isDeceased;
    address payable[] familyWallets;
    mapping(address => uint) inheritance;

    // - transfer some ether as the value for granny's fortune
    constructor() payable {
        owner = msg.sender;
        fortune = msg.value;
        isDeceased = false;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier mustBeDeceased {
        require(isDeceased == true);
        _;
    }


    // - function for granny to set alloted pay for other family members :)
    function setInheritanceForAddress(address payable wallet, uint amount) public onlyOwner {
        familyWallets.push(wallet);
        inheritance[wallet] = amount;
    }

    // - function to disburse inheritance to family members when granny is deceased :(
    function payout() private mustBeDeceased {
        for(uint i = 0; i < familyWallets.length; i++) {
            uint allotedPay = inheritance[familyWallets[i]];
            familyWallets[i].transfer(allotedPay);
        }
    }

    // - function to trigger isDeceased variable. mocking an oracle
    function hadDeceased() public onlyOwner {
        isDeceased = true;
        payout();
    }

}