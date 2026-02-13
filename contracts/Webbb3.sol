//SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

enum Choice { None, Option1, Option2 }

struct Voting {
    string option1;
    uint votes1;
    string option2;
    uint votes2;
    uint maxDate;
}

struct Vote {
    uint choice;
    uint date;
}

event VotingCreated(uint indexed votingId, string option1, string option2, uint maxDate);

contract Webbb3 {
    address immutable owner;
    uint public currentVoting = 0;
    Voting[] public votings;
    mapping(uint => mapping (address => Vote)) public votes;

    constructor() {
        owner = msg.sender;
    }

    function getCurrentVoting() public view returns (Voting memory) {
        require(votings.length > 0, "No voting available");

        return votings[currentVoting];
    }

    function addVoting(string memory option1, string memory option2, uint timeToVote) public {
        require(msg.sender == owner, "Only owner can add a new voting");
        require(timeToVote > 60, "Invalid voting duration");

        uint maxDate = timeToVote + block.timestamp;
        
        votings.push(Voting({
            option1: option1,
            votes1: 0,
            option2: option2,
            votes2: 0,
            maxDate: maxDate
        }));

        currentVoting = votings.length - 1;
        emit VotingCreated(currentVoting, option1, option2, maxDate);
    }

    function addVote(uint choice) public {
        require(choice == 1 || choice == 2, "Invalid choice");
        require(votings.length > 0, "No open votings");
        require(votes[currentVoting][msg.sender].date == 0, "You have already voted");

        Voting storage voting = votings[currentVoting];

        require(voting.maxDate > block.timestamp, "Voting is closed.");

        votes[currentVoting][msg.sender].choice = choice;
        votes[currentVoting][msg.sender].date = block.timestamp;

        if (choice == 1) {
            voting.votes1++;
        } else {
            voting.votes2++;
        }
    }
}