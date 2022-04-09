// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**
 * @title SubCoin
 * @dev a token simulation to mint, send and burn tokens
 */
contract SubCoin {

    address immutable public minter;
    mapping(address => uint) public balances;
    event Sent(address from, address to, uint amount);
    event Burnt(address by, uint amount);
    address[] public holders;
    uint public totalSupply;
    uint public circulation;


    constructor() {
        minter = msg.sender;
        totalSupply = 21000000 ether;
    }


    /**
     * @dev mint new tokens to a specific address
     * @param to address to send freshly minted tokens
     * @param amount number of tokens 
     */
    function mint(address to, uint amount) public {
        require(msg.sender == minter, "unauthorized");
        require(circulation + amount < totalSupply, "insufficient tokens left");

        // check if the address already holds tokens, otherwise add to holders
        if (balances[to] == 0) {
            holders.push(to);
        }

        // update balances accordingly
        balances[to] = amount;
        circulation += amount;
    }


    /**
     * @dev send tokens to an address from a token holder
     * @param to address to send tokens
     * @param amount number of tokens
     */
    function send(address to, uint amount) public {
        require(amount <= balances[msg.sender], 'insufficient balance!');

        // check if the receiver already holds tokens, otherwise add to holders
        if (balances[to] == 0) {
            holders.push(to);
        }

        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Sent(msg.sender, to, amount);
        
        // check if new balance is zero, so as to remove account from holders array
        if (balances[msg.sender] == 0) {
            uint index = findIndex(holders, msg.sender);
            if (index != 1 ether) {
                holders[index] = holders[holders.length - 1];
                holders.pop();
            }
        }
    }


    /**
     * @dev remove tokens from circulation - effectively reducing the total supply
     * @param amount number of tokens
     */
    function burn(uint amount) public {
        require(amount <= balances[msg.sender], 'insufficient balance!');
        balances[msg.sender] -= amount;
        circulation -= amount;
        totalSupply -= amount;
        emit Burnt(msg.sender, amount);

        // check if new balance is zero, so as to remove account from holders array
        if (balances[msg.sender] == 0) {
            uint index = findIndex(holders, msg.sender);
            if (index != 1 ether) {
                holders[index] = holders[holders.length - 1];
                holders.pop();
            }
        }
    }


    /**
     * @dev number of people holding the subcoin
     * @return number of token holders
     */
    function holdersCount() public view returns(uint) {
        return holders.length;
    }
    

    /**
     * @dev helper function to find the index of an address in the holders array
     * @param arrayInstance address array to carry out search
     * @param target address to find
     * @return index of the target if found, otherwise returns 1000000000000000000 (1 ether)
     */
    function findIndex(address[] memory arrayInstance, address target) internal pure returns(uint) {
        for (uint i = 0; i < arrayInstance.length; ++i) {
            if (arrayInstance[i] == target) {
                return i;
            }
        }
        return 1 ether;
    }

}