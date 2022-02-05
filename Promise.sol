pragma solidity >=0.7.0 <0.9.0;

contract Promise {
    address goodPromise;
    address badPromise;
    uint256 numberOfCheckersGoodVote;
    uint256 numberOfCheckersVoted;
    uint256 numberOfCheckers;
    uint256 numberOfCheckersToPass;

    uint256 expirationTime;

    address[] checkers;
    mapping(address => Vote) results;

    constructor(address _goodPromise, address _badPromise, address[] memory _checkers, uint8 _numberOfCheckersToPass, uint256 _expirationTime) payable {
        require(_goodPromise != _badPromise, "not allowed to give promise to yourself");
        require(_expirationTime > block.timestamp, "not allowed to set expiration time in the past");

        goodPromise = _goodPromise;
        badPromise = _badPromise;
        numberOfCheckersToPass = _numberOfCheckersToPass;
        numberOfCheckersGoodVote = 0;
        numberOfCheckersVoted = 0;
        numberOfCheckers = _checkers.length;
        expirationTime = _expirationTime;

        for (uint i = 0; i < _checkers.length; i++) {
            require(_checkers[i] != _goodPromise, "giver of promise cannot validate its own promise");
            require(results[_checkers[i]] == Vote.notAllowed, "one address can only represent one vote");

            results[_checkers[i]] = Vote.notGiven;
            checkers.push(_checkers[i]);
        }
    }

    function vote(bool isGood) external {
        if(block.timestamp > expirationTime) {
            selfdestruct(payable(badPromise));
        }

        require(results[msg.sender] == Vote.notGiven, "Not allowed to give vote");

        numberOfCheckersVoted++;

        if(isGood){
            numberOfCheckersGoodVote++;
            results[msg.sender] = Vote.Good;
        } else {
            results[msg.sender] = Vote.Bad;
        }

        if(numberOfCheckersGoodVote == numberOfCheckersToPass) {
            selfdestruct(payable(goodPromise));
        }

        if(numberOfCheckers - numberOfCheckersVoted + numberOfCheckersGoodVote < numberOfCheckersToPass) {
            selfdestruct(payable(badPromise));
        }
    }

    function getVotes() external view returns (address[] memory checkersList, Vote[] memory checkersVotes) {
        require(address(0) == msg.sender, "do not write this as a transaction and call it with 0x0 address");
        for (uint i = 0; i < checkers.length; i++) {
            checkersList[i] = checkers[i];
            checkersVotes[i] = results[checkers[i]];
        }
    }

    enum Vote {
        notAllowed,
        notGiven,
        Good,
        Bad
    }
}
