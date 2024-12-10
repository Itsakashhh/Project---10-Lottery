// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    address[] public players;
    bool public isActive;

    constructor() {
        owner = msg.sender;
        isActive = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier lotteryActive() {
        require(isActive, "Lottery is not active");
        _;
    }

    function startLottery() public onlyOwner {
        require(!isActive, "Lottery is already active");
        delete players;
        isActive = true;
    }

    function enterLottery() public payable lotteryActive {
        require(msg.value == 1 ether, "Ticket price is 1 ETH");
        players.push(msg.sender);
    }

    function endLottery() public onlyOwner lotteryActive {
        require(players.length > 0, "No players in the lottery");

        uint winnerIndex = createRandomNumber() % players.length;
        address winner = players[winnerIndex];

        // Transfer the prize to the winner
        payable(winner).transfer(address(this).balance);

        // Reset the lottery
        isActive = false;
    }

    function createRandomNumber() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players)));
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }


    function withdraw() public onlyOwner {
        require(!isActive, "Cannot withdraw while lottery is active");
        payable(owner).transfer(address(this).balance);
    }
}
