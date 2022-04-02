// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**
 * @title Will
 * @dev a contract to share inheritance to granny's family members according to allotment
 */
contract Will {

    address immutable owner;
    uint fortune;
    bool isDeceased;
    address payable[] familyWallets;
    mapping(address => uint) inheritance;

    /**
     * @dev transfer some ether as the value for granny's fortune
     */
    constructor() payable {
        owner = msg.sender;
        fortune = msg.value;
        isDeceased = false;
    }

    /**
     * @dev modifier to allow only the owner of the contract perform an operation
     */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev modifier to allow operation only when granny is deceased
     */
    modifier mustBeDeceased {
        require(isDeceased == true);
        _;
    }


    /**
     * @dev function for granny to set alloted pay for other family members :)
     * @param wallet address to set inheritance for
     * @param amount in wei to allot to the given wallet address
     */
    function setInheritanceForAddress(address payable wallet, uint amount) public onlyOwner {
        familyWallets.push(wallet);
        inheritance[wallet] = amount;
    }


    /**
     * @dev function to disburse inheritance to family members when granny is deceased :(
     */
    function payout() private mustBeDeceased {
        for(uint i = 0; i < familyWallets.length; i++) {
            uint allotedPay = inheritance[familyWallets[i]];
            familyWallets[i].transfer(allotedPay);
        }
    }
    

    /**
     * @dev function to trigger isDeceased variable. mocking an oracle
     */
    function hadDeceased() public onlyOwner {
        isDeceased = true;
        payout();
    }

}