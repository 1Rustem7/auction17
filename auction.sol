// указываем версию Solidity, которую мы будем использовать
pragma solidity ^0.8.0;

// создаем контракт
contract VipaAuction {

    // структура для хранения информации об участнике аукциона
    struct Bidder {
        address payable bidderAddress;
        uint256 amount;
    }

    // массив для хранения участников аукциона
    Bidder[] public bidders;

    // адрес владельца контракта (адрес кошелька, на который будут поступать средства от продажи билетов)
    address payable public owner;

    // количество билетов, которые можно купить за одну транзакцию
    uint256 public constant TICKET_LIMIT = 3;

    // минимальная ставка на аукционе
    uint256 public constant MINIMUM_BID = 100000000000000; // 0.0001 тбнб

    // время, на которое открыт аукцион (в секундах)
    uint256 public constant AUCTION_TIME = 300 seconds; // 5 минут

    // время начала аукциона
    uint256 public auctionStart;

    // модификаторы для проверки состояния аукциона
    modifier onlyBeforeAuctionStart() {
        require(block.timestamp < auctionStart, "Auction has already started");
        _;
    }

    modifier onlyDuringAuction() {
        require(block.timestamp >= auctionStart && block.timestamp < auctionStart + AUCTION_TIME, "Auction is not currently open");
        _;
    }

    modifier onlyAfterAuction() {
        require(block.timestamp >= auctionStart + AUCTION_TIME, "Auction is still open");
        _;
    }

    // событие для уведомления об окончании аукциона и распределении билетов
    event AuctionEnded(address winner, uint256 amount, uint256 tickets);

    // конструктор контракта
    constructor() {
        owner = payable(msg.sender);
    }

    // функция для начала аукциона
    function startAuction() public onlyBeforeAuctionStart {
        auctionStart = block.timestamp;
    }

    // функция для участия в аукционе
    function bid() public payable onlyDuringAuction {
        require(msg.value >= MINIMUM_BID, "Bid amount is too low");

        // проверяем, что участник не пытается купить больше, чем лимит разрешенных билетов
        uint256 ticketsToBuy = msg.value / MINIMUM_BID;
        require(ticketsToBuy <= TICKET_LIMIT, "Exceeds the ticket limit");

        // добавляем участника в массив участников аукциона
        bidders.push(Bidder(payable(msg.sender), msg.value));
    }

    // функция для окончания аукциона и распределения билетов
    function endAuction() public onlyAfterAuction {
require(bidders.length > 0, "No bids have been placed");

 // сортируем участников аукциона по убыванию ставок
    sortBidders();

    // распределяем билеты, начиная с участника с наивысшей ставкой
    uint256 remainingTickets = TICKET_LIMIT * bidders.length;
    for (uint i = 0; i < bidders.length; i++) {
        uint256 ticketsToAllocate = (bidders[i].amount / MINIMUM_BID) > remainingTickets ? remainingTickets : (bidders[i].amount / MINIMUM_BID);
        if (ticketsToAllocate == 0) {
            break;
        }

        remainingTickets -= ticketsToAllocate;

        // отправляем билеты на адрес участника
        // здесь можно использовать NFT-стандарт (например, ERC-721), чтобы создать уникальные билеты
        // в данном примере мы просто отправляем ETH на адрес участника
        bidders[i].bidderAddress.transfer(ticketsToAllocate * MINIMUM_BID);

        emit AuctionEnded(bidders[i].bidderAddress, bidders[i].amount, ticketsToAllocate);
    }

    // возвращаем средства остальным участникам аукциона
    for (uint i = 0; i < bidders.length; i++) {
        if ((bidders[i].amount / MINIMUM_BID) > remainingTickets) {
            bidders[i].bidderAddress.transfer(bidders[i].amount - remainingTickets * MINIMUM_BID);
        }
    }

    // отправляем средства на адрес владельца контракта
    owner.transfer(address(this).balance);
}

// вспомогательная функция для сортировки участников аукциона по убыванию ставок
function sortBidders() private {
    for (uint i = 0; i < bidders.length; i++) {
        for (uint j = i + 1; j < bidders.length; j++) {
            if (bidders[i].amount < bidders[j].amount) {
                Bidder memory tempBidder = bidders[i];
                bidders[i] = bidders[j];
                bidders[j] = tempBidder;
            }
        }
    }
}

}
