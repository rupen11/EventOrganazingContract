// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EventOrganize {

    struct Event {
        address organizer;
        uint date;
        string name;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping (uint => Event) public events;
    mapping (address => mapping(uint => uint)) public tickets;
    uint public ID;

    modifier eventChecking(Event storage _event){
        require(_event.date != 0, "Event does not exist!");
        require(_event.date > block.timestamp, "Event booking is close!");
        _;
    }
    
    function createEvent(uint _date, string memory _name, uint _price, uint _ticketCount) external{
        require(_date > block.timestamp, "You can organize event for future!");
        require(_ticketCount > 0, "Event must have atleast 1 ticket!");
        events[ID] = Event(msg.sender, _date, _name, _price, _ticketCount, _ticketCount);
        ID++;
    }

    function buyTicket(uint _quantity, uint _ID) payable external eventChecking(events[_ID]) returns(uint) {
        Event storage _event = events[_ID];
        require((_event.price * _quantity) == msg.value, "Ethers is not enough!");
        require(_event.ticketRemain >= _quantity, "We don't have enough tickets!");
        _event.ticketRemain -= _quantity;
        tickets[msg.sender][_ID] += _quantity;
        return _event.date;
    }

    function transferTicket(uint _quantity, uint _ID, address _to) external eventChecking(events[_ID]){
        require(tickets[msg.sender][_ID] >= _quantity, "You don't have enough ticket to transfer!");
        tickets[msg.sender][_ID] -= _quantity;
        tickets[_to][_ID] += _quantity;
    }

    function cancelEvent(uint _ID) external{
        require(events[_ID].date > block.timestamp, "Event already occured");
        require(events[_ID].organizer == msg.sender, "You can not cancel this event");
        events[_ID].date = 0;
    }

    function withdrawMoney(uint _ID) payable external{
        require(events[_ID].date == 0, "You can not return tickets, if event cancel then you can withdraw your money");
        require(tickets[msg.sender][_ID] > 0, "You already withdraw your money");
        payable(msg.sender).transfer(tickets[msg.sender][_ID] * events[_ID].price);
        tickets[msg.sender][_ID] = 0;
    }

}