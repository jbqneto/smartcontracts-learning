//SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

struct Voting {
    string title;
    string[] options;
    uint[] votes;
    uint maxDate;
}

struct Vote {
    uint choice;
    uint date;
}

event VotingCreated(uint indexed votingId, uint maxDate);
event VoteCast(uint indexed votingId, uint choice);

contract PublicVoting {
    address immutable owner;
    Voting[] public votings;
    uint256 public constant CREATE_VOTING_FEE = 0.0001 ether;

    mapping(uint => mapping (address => Vote)) public votes;

    constructor() {
        owner = msg.sender;
    }

    function addVoting(string memory title, string[] memory options, uint timeToVote) public payable {
        require(msg.value > CREATE_VOTING_FEE, "Insufficient creation fee");
        require(options.length > 1, "Required at least 2 options");
        require(options.length < 6, "Required at maximum 6 options");
        require(bytes(title).length > 5, "Title too short");
        require(timeToVote > 60, "Invalid voting duration");

        uint maxDate = timeToVote + block.timestamp;
        uint[] memory currentVotes = new uint[](options.length);
        
        votings.push(Voting({
            title: title,
            options: options,
            votes: currentVotes,
            maxDate: maxDate
        }));

        uint currentVoting = votings.length - 1;

        emit VotingCreated(currentVoting, maxDate);
    }

    function vote(uint votingId, uint choice) public {
        require(votings.length > votingId, "Voting not found");
        require(votes[votingId][msg.sender].date == 0, "You have already voted on this.");

        Voting storage voting = votings[votingId];

        require(voting.options.length > choice, "Invalid choice");
        require(voting.maxDate > block.timestamp, "Voting is closed.");

        votes[votingId][msg.sender].choice = choice;
        votes[votingId][msg.sender].date = block.timestamp;
        voting.votes[choice] += 1;

        emit VoteCast(votingId, choice);
    }

    function getVoting(uint id) public view returns (Voting memory) {
        require(votings.length > id, "Voting not found!");

        return votings[id];
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw funds.");

        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner).transfer(balance);

    }

}