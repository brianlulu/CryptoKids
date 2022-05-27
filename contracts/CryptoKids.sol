// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7; // specify complier's version or features or check

contract CryptoKids {
    
    address owner;

    constructor() {
        owner = msg.sender;
    }

    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    Kid[] public kids;

    function addKid(
        address payable walletAddress, 
        string memory firstName, 
        string memory lastName, 
        uint releaseTime, 
        uint amount, 
        bool canWithdraw) public {
            kids.push(Kid(
                walletAddress,
                firstName,
                lastName,
                releaseTime,
                amount,
                canWithdraw
            ));
    }

    function deposit(address walletAddress) payable public {
        addToKidsBalance(walletAddress);
    }  

    //TODO: check if it work
    function getKidIndex(address walletAddress) private view returns(uint) {
        for( uint i = 0; i < kids.length; i++) {
            if ( kids[i].walletAddress == walletAddress) {
                return i;
            }
        }
        return kids.length; // if the address is not a kid, return lengths of the kids which is always 1 larger than the last index
    }

    function addToKidsBalance(address walletAddress) private {
        uint theKidIndex = getKidIndex(walletAddress);
        if (theKidIndex < kids.length) {
            kids[theKidIndex].amount += msg.value;
        }
    }

    function avaiableToWithdraw(address walletAddress) public returns(bool) {
        uint i = getKidIndex(walletAddress);

        // block.timestamp check the current time, but this can be 15 mins difference 
        // accurate timing should use other variable
        if (block.timestamp > kids[i].releaseTime) {
            kids[i].canWithdraw = true;
            return true;
        }

        return false;
    }
    
    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    function withdraw(address payable walletAddress, uint amount) payable public {
        uint i = getKidIndex(walletAddress);
        require(msg.sender == kids[i].walletAddress, "You are not allowed to withdraw! Address Does Not Matched!");
        require(avaiableToWithdraw(walletAddress), "You are not allowed to withdraw! Time has not passed!");
        require(kids[i].amount >= amount, "You are not allowed to withdraw! No Sufficient Amount!");
        kids[i].walletAddress.transfer(amount);
        kids[i].amount -= amount;
    }

}

