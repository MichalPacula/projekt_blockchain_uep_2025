// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract  TicketNFT is ERC721URIStorage, Ownable {
    uint256 public currentTokenId;
    uint256 public ticketPrice;

    constructor(uint256 _price) ERC721("EventTicket", "ETIX") {
        ticketPrice = _price;
    }

    function mintTicket(string memory tokenURI) public payable {
        require(msg.value >= ticketPrice, "Not enough ETH sent");

        currentTokenId++;
        _safeMint(msg.sender, currentTokenId);
        _setTokenURI(currentTokenId, tokenURI);
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}