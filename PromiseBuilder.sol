pragma solidity ^0.8.0;

import "./Promise.sol";

contract PromiseBuilder {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function givePromise(address _goodPromise, address _badPromise, address[] memory _checkers, uint8 _numberOfCheckersToPass, uint256 _expirationTime) payable external returns(address) {
        require(msg.value != 0, "require to put eth at stake of a promise");

        uint myShare = msg.value * 1 / 100;

        address promiseAddress = address(new Promise{value: msg.value - myShare }(_goodPromise, _badPromise, _checkers, _numberOfCheckersToPass, _expirationTime));
        payable(owner).transfer(myShare);

        return promiseAddress;
    }
}
