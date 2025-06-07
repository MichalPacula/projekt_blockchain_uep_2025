// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract  TicketNFT is ERC721URIStorage, Ownable {
    uint256 public currentTokenId;

    struct Event {
        string name;
        string date;
        string location;
        uint256 ticketPrice;
        uint256 maxTickets;
        uint256 ticketsSold;
    }

    mapping(uint256 => Event) public events;
    uint256 public currentEventId;

    mapping(uint256 => uint256) public ticketToEvent;

    event TicketMinted(address indexed buyer, uint256 tokenId, uint256 eventId);

    constructor() ERC721("EventTicket", "ETIX") {}

    function createEvent(
        string memory name,
        string memory date,
        string memory location,
        uint256 ticketPrice,
        uint256 maxTickets
    ) public onlyOwner {
        currentEventId++;
        events[currentEventId] = Event(name, date, location, ticketPrice, maxTickets, 0);
    }

    function mintTicket(uint256 eventId, string memory tokenURI) public payable {
        Event storage _event = events[eventId];
        require(_event.ticketPrice > 0, "Event does not exist");
        require(msg.value >= _event.ticketPrice, "Not enough ETH sent");
        require(_event.ticketsSold < _event.maxTickets, "Tickets sold out");

        currentTokenId++;
        _safeMint(msg.sender, currentTokenId);
        _setTokenURI(currentTokenId, tokenURI);

        ticketToEvent[currentTokenId] = eventId;
        _event.ticketsSold++;

        emit TicketMinted(msg.sender, currentTokenId, eventId);

        if (msg.value > _event.ticketPrice) {
            payable(msg.sender).transfer(msg.value - _event.ticketPrice);
        }
    }

    function refundTicket(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You don't onw this ticket");
        uint256 eventId = ticketToEvent[tokenId];
        Event storage _event = events[eventId];
        require(_event.ticketsSold > 0, "No tickets sold for event");

        _burn(tokenId);
        _event.ticketsSold--;

        payable(msg.sender).transfer(_event.ticketPrice);
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}