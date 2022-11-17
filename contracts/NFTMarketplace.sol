// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol"; // in the upgradable contracts we need to remove constructor and replace that with Initializer
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract NFTMarketplace is
    Initializable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721HolderUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;
    // address payable owner;

    mapping(address => mapping(uint256 => MarketItem)) public idToMarketItem;

    // fetch all items on frontend and then refactor out according to the needs;
    // MarketItem[] public marketUnsoldItems;

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ERC721_init("DreamHub", "DH");
        // DreamHubMinterAddress = minterAddress;
    }

    function _authorizeUpgrade(address _newImplementation)
        internal
        override
        onlyOwner
    {}

    struct MarketItem {
        address nftContractAddress;
        uint256 tokenId;
        address payable creator;
        ListingDetail listingDetails;
        // MULTIPLIED BY 10
        uint8 royalty;
    }

    struct ListingDetail {
        address payable seller;
        address payable owner;
        address payable lastBidder;
        uint256 startDate;
        uint256 endDate;
        // MULTIPLIED BY 10
        uint8 bidGap;
        // MULTIPLIED BY 1e18
        uint256 minimumBid;
        // MULTIPLIED BY 1e18
        uint256 price;
        listingStates listingState;
    }

    event MarketItemCreated(
        address nftContractAddress,
        uint256 indexed tokenId,
        address creator,
        address seller,
        address owner,
        uint256 price,
        // MULTIPLIED BY 10
        uint8 royalty,
        bool sold
    );

    enum listingStates {
        notListed,
        onSale,
        openForBids,
        onAuction
    }

    modifier checkDuration(address nftContractAddress, uint256 tokenId) {
        if (
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .listingState ==
            listingStates.openForBids ||
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .listingState ==
            listingStates.onAuction
        ) {
            require(
                block.timestamp >=
                    idToMarketItem[nftContractAddress][tokenId]
                        .listingDetails
                        .startDate &&
                    block.timestamp <=
                    idToMarketItem[nftContractAddress][tokenId]
                        .listingDetails
                        .endDate,
                "Listing Duration has ended."
            );
        }
        _;
    }

    modifier listingRequirements(address nftContractAddress, uint256 tokenId) {
        require(
            ERC721(nftContractAddress).ownerOf(tokenId) == msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            ERC721(nftContractAddress).isApprovedForAll(
                msg.sender,
                address(this)
            ),
            "Token not Approved."
        );
        _;
    }

    /* Mints a token and lists it in the marketplace */
    function CreateItem(string memory tokenURI, uint8 royalty)
        public
        payable
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        _listItem(address(this), newTokenId, royalty);
        return newTokenId;
    }

    function _listItem(
        address nftContractAddress,
        uint256 tokenId,
        uint8 royalty
    ) internal {
        idToMarketItem[nftContractAddress][tokenId]
            .nftContractAddress = nftContractAddress;
        idToMarketItem[nftContractAddress][tokenId].tokenId = tokenId;
        idToMarketItem[nftContractAddress][tokenId].royalty = royalty;
        idToMarketItem[nftContractAddress][tokenId].creator = payable(
            msg.sender
        );
    }

    function _listing(
        address nftContractAddress,
        uint256 tokenId,
        listingStates listingState,
        uint256 price,
        uint256 minimumBid,
        uint256 startDate,
        uint256 endDate,
        uint8 bidGap
    ) internal {
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .seller = payable(msg.sender);
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .owner = payable(address(this));
        if (listingState != listingStates.onAuction) {
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .price = price;
        }
        if (
            listingState == listingStates.onAuction ||
            listingState == listingStates.openForBids
        ) {
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .bidGap = bidGap;
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .minimumBid = minimumBid;
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .startDate = startDate;
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .endDate = endDate;
        }
    }

    /* allows someone to resell a token they have purchased */
    // MUST BE APPROVED FIRST IF NOT APPROVED, USING setApprovedForAll, CHECK WITH isApprovedForAll;
    function ListOnSale(
        address nftContractAddress,
        uint256 tokenId,
        uint256 price
    ) public listingRequirements(nftContractAddress, tokenId) {
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .listingState = listingStates.onSale;
        _listing(
            nftContractAddress,
            tokenId,
            listingStates.onSale,
            price,
            0,
            0,
            0,
            0
        );
    }

    /* allows someone to resell a token they have purchased */
    // MUST BE APPROVED FIRST IF NOT APPROVED, USING setApprovedForAll, CHECK WITH isApprovedForAll;
    function ListOnAuction(
        address nftContractAddress,
        uint256 tokenId,
        uint256 minimumBid,
        uint256 startDate,
        uint256 endDate,
        uint8 bidGap
    ) public listingRequirements(nftContractAddress, tokenId) {
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .listingState = listingStates.onAuction;
        _listing(
            nftContractAddress,
            tokenId,
            listingStates.onAuction,
            0,
            minimumBid,
            startDate,
            endDate,
            bidGap
        );
    }

    /* allows someone to resell a token they have purchased */
    // MUST BE APPROVED FIRST IF NOT APPROVED, USING setApprovedForAll, CHECK WITH isApprovedForAll;
    function ListInOpenForBids(
        address nftContractAddress,
        uint256 tokenId,
        uint256 price,
        uint256 minimumBid,
        uint256 startDate,
        uint256 endDate,
        uint8 bidGap
    ) public listingRequirements(nftContractAddress, tokenId) {
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .listingState = listingStates.openForBids;
        _listing(
            nftContractAddress,
            tokenId,
            listingStates.openForBids,
            price,
            minimumBid,
            startDate,
            endDate,
            bidGap
        );
    }

    function removeListing(address nftContractAddress, uint256 tokenId)
        external
        nonReentrant
    {
        require(
            idToMarketItem[nftContractAddress][tokenId].listingDetails.seller ==
                msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .lastBidder == address(0),
            "Bids Already Placed"
        );
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .owner = payable(msg.sender);
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .seller = payable(address(0));

        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .listingState = listingStates.notListed;
    }

    function BidMarketItem(address nftContractAddress, uint256 tokenId)
        external
        payable
        nonReentrant
        checkDuration(nftContractAddress, tokenId)
    {
        require(
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .lastBidder == address(0)
                ? msg.value >=
                    idToMarketItem[nftContractAddress][tokenId]
                        .listingDetails
                        .minimumBid
                : (msg.value >=
                    (idToMarketItem[nftContractAddress][tokenId]
                        .listingDetails
                        .minimumBid +
                        (((idToMarketItem[nftContractAddress][tokenId]
                            .listingDetails
                            .minimumBid / 100) *
                            idToMarketItem[nftContractAddress][tokenId]
                                .listingDetails
                                .bidGap) / 10))),
            "Value sent must be greater than MinimumBid"
        );
        if (
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .lastBidder != address(0)
        ) {
            payable(
                idToMarketItem[nftContractAddress][tokenId]
                    .listingDetails
                    .lastBidder
            ).transfer(
                    idToMarketItem[nftContractAddress][tokenId]
                        .listingDetails
                        .minimumBid
                );
        }
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .minimumBid = msg.value;
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .lastBidder = payable(msg.sender);
        if (IERC721(nftContractAddress).ownerOf(tokenId) != address(this)) {
            IERC721(nftContractAddress).safeTransferFrom(
                idToMarketItem[nftContractAddress][tokenId]
                    .listingDetails
                    .seller,
                address(this),
                tokenId
            );
        }
    }

    function _buy(
        address nftContractAddress,
        uint256 tokenId,
        uint256 price,
        bool buyingType
    ) internal {
        address seller = idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .seller;
        listingStates listingState = idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .listingState;
        // idToMarketItem[nftContractAddress][tokenId].listingDetails.owner = payable(msg.sender);
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .listingState = listingStates.notListed;
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .seller = payable(address(0));
        ERC721 nftContract = ERC721(nftContractAddress);
        if (
            listingState == listingStates.onSale ||
            (listingState == listingStates.openForBids &&
                idToMarketItem[nftContractAddress][tokenId]
                    .listingDetails
                    .lastBidder ==
                address(0))
        ) {
            nftContract.safeTransferFrom(seller, address(this), tokenId);
        }
        if (buyingType) {
            if (
                listingState == listingStates.onAuction ||
                listingState == listingStates.openForBids
            ) {
                payable(
                    idToMarketItem[nftContractAddress][tokenId]
                        .listingDetails
                        .lastBidder
                ).transfer(
                        idToMarketItem[nftContractAddress][tokenId]
                            .listingDetails
                            .minimumBid
                    );
                idToMarketItem[nftContractAddress][tokenId]
                    .listingDetails
                    .lastBidder = payable(address(0));
            }
        }
        nftContract.safeTransferFrom(
            address(this),
            idToMarketItem[nftContractAddress][tokenId].listingDetails.owner,
            tokenId
        ); // flaw 2
        uint256 marketplaceFee = ((price / 100) * 25);
        uint256 royaltyFee = ((price / 100) *
            (
                nftContractAddress == address(this)
                    ? idToMarketItem[nftContractAddress][tokenId].royalty
                    : 25
            ));
        payable(owner()).transfer(marketplaceFee / 10);
        payable(
            nftContractAddress == address(this)
                ? idToMarketItem[nftContractAddress][tokenId].creator
                : OwnableUpgradeable(nftContractAddress).owner()
        ).transfer(royaltyFee / 10);
        payable(seller).transfer(
            ((10 * price) - royaltyFee - marketplaceFee) / 10
        );
    }

    function approveBid(address nftContractAddress, uint256 tokenId) public {
        require(
            idToMarketItem[nftContractAddress][tokenId].listingDetails.seller ==
                msg.sender,
            "Only item owner can perform this operation"
        );
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .owner = payable(
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .lastBidder
        );
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .lastBidder = payable(address(0));
        // false when bid is approved
        _buy(
            nftContractAddress,
            tokenId,
            idToMarketItem[nftContractAddress][tokenId]
                .listingDetails
                .minimumBid,
            false
        );
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function BuyMarketItem(address nftContractAddress, uint256 tokenId)
        public
        payable
        checkDuration(nftContractAddress, tokenId)
    {
        uint256 price = idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .price;
        require(
            msg.value >= price,
            "Value sent is lesser than the Asking Price."
        );
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
        idToMarketItem[nftContractAddress][tokenId]
            .listingDetails
            .owner = payable(msg.sender);
        // true when its bought
        _buy(nftContractAddress, tokenId, price, true);
    }
}