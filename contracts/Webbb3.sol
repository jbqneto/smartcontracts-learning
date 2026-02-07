//SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

struct Voting {
    string option1;
    uint votes1;
    string option2;
    uint votes2;
    uint maxDate;
}

contract Webbb3 {
    address owner;
    uint public currentVoting;
    Voting[] public votings;

    constructor() {
        owner = msg.sender;
    }

    function getCurrentVoting() public view returns (Voting memory) {
        return votings[currentVoting];
    }

    function addVoting(string memory option1, string memory option2, uint timeToVote) public {
        require(msg.sender == owner, "Only owner can add a new voting");
        
        Voting memory vote;
        vote.option1 = option1;
        vote.option2 = option2;
        vote.maxDate = timeToVote + block.timestamp;
        votings.push(vote);
        currentVoting = votings.length - 1;
    }
}