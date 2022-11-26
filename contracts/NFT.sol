import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Example contract that uses Airnode RRP to receive QRNG services
/// @notice This contract is not secure. Do not use it in production. Refer to
/// the contract for more information.
/// @dev See README.md for more information.
contract QrngRandom is RrpRequesterV0, Ownable {
    event RequestedUint256(bytes32 indexed requestId);
    event ReceivedUint256(bytes32 indexed requestId, uint256 response);
    event RequestedUint256Array(bytes32 indexed requestId, uint256 size);
    event ReceivedUint256Array(bytes32 indexed requestId, uint256[] response);

    // These variables can also be declared as `constant`/`immutable`.
    // However, this would mean that they would not be updatable.
    // Since it is impossible to ensure that a particular Airnode will be
    // indefinitely available, you are recommended to always implement a way
    // to update these parameters.
    address public airnode;
    bytes32 public endpointIdUint256;
    bytes32 public endpointIdUint256Array;
    address public sponsorWallet;
    address public NFT_CONTRACT;
    struct LatestRequest {
        bytes32 requestId;
        uint256 randomNumber;
    }
    LatestRequest public latestRequest;

    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    /// @dev RrpRequester sponsors itself, meaning that it can make requests
    /// that will be fulfilled by its sponsor wallet. See the Airnode protocol
    /// docs about sponsorship for more information.
    /// @param _airnodeRrp Airnode RRP contract address
    constructor(address _airnodeRrp, address _NFTContract) RrpRequesterV0(_airnodeRrp) {
        NFT_CONTRACT = _NFTContract;
    }

    /// @notice Sets parameters used in requesting QRNG services
    /// @dev No access control is implemented here for convenience. This is not
    /// secure because it allows the contract to be pointed to an arbitrary
    /// Airnode. Normally, this function should only be callable by the "owner"
    /// or not exist in the first place.
    /// @param _airnode Airnode address
    /// @param _endpointIdUint256 Endpoint ID used to request a `uint256`
    /// @param _endpointIdUint256Array Endpoint ID used to request a `uint256[]`
    /// @param _sponsorWallet Sponsor wallet address
    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256,
        bytes32 _endpointIdUint256Array,
        address _sponsorWallet
    ) external onlyOwner {
        // Normally, this function should be protected, as in:
        // require(msg.sender == owner, "Sender not owner");
        airnode = _airnode;
        endpointIdUint256 = _endpointIdUint256;
        endpointIdUint256Array = _endpointIdUint256Array;
        sponsorWallet = _sponsorWallet;
    }

    /// @notice Requests a `uint256`
    /// @dev This request will be fulfilled by the contract's sponsor wallet,
    /// which means spamming it may drain the sponsor wallet. Implement
    /// necessary requirements to prevent this, e.g., you can require the user
    /// to pitch in by sending some ETH to the sponsor wallet, you can have
    /// the user use their own sponsor wallet, you can rate-limit users.
    function makeRequestUint256() external {
        require(
            msg.sender == owner() || msg.sender == NFT_CONTRACT,
            "You dont have right to make request!"
        );
        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256,
            address(this),
            sponsorWallet,
            address(this),
            this.fulfillUint256.selector,
            ""
        );
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        emit RequestedUint256(requestId);
    }

    /// @notice Called by the Airnode through the AirnodeRrp contract to
    /// fulfill the request
    /// @dev Note the `onlyAirnodeRrp` modifier. You should only accept RRP
    /// fulfillments from this protocol contract. Also note that only
    /// fulfillments for the requests made by this contract are accepted, and
    /// a request cannot be responded to multiple times.
    /// @param requestId Request ID
    /// @param data ABI-encoded response
    function fulfillUint256(bytes32 requestId, bytes calldata data)
        external
        onlyAirnodeRrp
    {
        require(
            expectingRequestWithIdToBeFulfilled[requestId],
            "Request ID not known"
        );
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint256 qrngUint256 = abi.decode(data, (uint256));
        // Do what you want with `qrngUint256` here...
        latestRequest.requestId = requestId;
        latestRequest.randomNumber = qrngUint256;
        emit ReceivedUint256(requestId, qrngUint256);
    }

    function getLatestRandom() public view returns (uint256) {
        return latestRequest.randomNumber;
    } /// @notice Requests a `uint256[]`

    /// @param size Size of the requested array
    function makeRequestUint256Array(uint256 size) external {
        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256Array,
            address(this),
            sponsorWallet,
            address(this),
            this.fulfillUint256Array.selector,
            // Using Airnode ABI to encode the parameters
            abi.encode(bytes32("1u"), bytes32("size"), size)
        );
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        emit RequestedUint256Array(requestId, size);
    }

    /// @notice Called by the Airnode through the AirnodeRrp contract to
    /// fulfill the request
    /// @param requestId Request ID
    /// @param data ABI-encoded response
    function fulfillUint256Array(bytes32 requestId, bytes calldata data)
        external
        onlyAirnodeRrp
    {
        require(
            expectingRequestWithIdToBeFulfilled[requestId],
            "Request ID not known"
        );
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint256[] memory qrngUint256Array = abi.decode(data, (uint256[]));
        // Do what you want with `qrngUint256Array` here...
        emit ReceivedUint256Array(requestId, qrngUint256Array);
    }
}

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
// import "@openzeppelin/contracts/utils/Strings.sol";
pragma solidity ^0.8.1;
struct Attributes {
    string uniqueAttribute;
    uint8 speice;
    uint8 rarity;
    uint8 BaseTrait;
    uint8 MaxStamina;
    uint8 Stamina;
    uint8 Attack;
    uint8 MaxHealth;
    uint8 health;
    uint8 Level;
    //check if attributes are setted
    bool set;
}

interface nftTokenURI {
    function getTokenURI(
        uint256 _tokenId,
        Attributes memory NFTData,
        uint256 level
    ) external view returns (string memory);
}

contract AaronNFT is ERC721, Ownable {
    uint256 public tokenIds;

    // Rarity Classes
    uint256 public price = 0.5 ether;

    address TokenUriAddress;
  mapping(uint=>Attributes) public _tokenIdToAttributes;
    // Starts From 0
    
    address private _burnAddress;
    QrngRandom public QRNG;

    constructor(address _TokenUriAddress,address qrngRandom) ERC721("MyToken", "MTK") {
        TokenUriAddress = _TokenUriAddress;
        QRNG= QrngRandom(qrngRandom);
        // Starts From 0
    }


    // baby.mature,max mature bird level
    mapping(uint256 => uint8) public level;

    event Minted(address indexed, uint256 indexed);
    event Rarity(uint256 indexed, uint256 indexed);


    function mintEgg(uint256 tNumber, address account)
        external
        payable
        onlyOwner
    {
        require(msg.value >= price * tNumber, "Price is low");
        for (uint256 i = 0; i < tNumber; i++) {
            uint256 newItemId = tokenIds++;
            _mint(account, newItemId);

            level[newItemId] = 1;
            _tokenIdToAttributes[newItemId] = selectAttrbiutes();
            selectRandomNftWithAttributes(newItemId);
            emit Rarity(newItemId, _tokenIdToAttributes[newItemId].rarity);
        }
        emit Minted(account, tNumber);
    }

    function selectRandomNftWithAttributes(uint256 _tokenId)
        internal
        returns (Attributes memory)
    {
        uint256 _rand = randomUniqueNft();
        if (_rand == 0) {
            _tokenIdToAttributes[_tokenId].speice = 0;
        } else if (_rand == 1) {
            _tokenIdToAttributes[_tokenId].speice = 1;
        } else if (_rand == 2) {
            _tokenIdToAttributes[_tokenId].speice = 2;
        } else if (_rand == 3) {
            _tokenIdToAttributes[_tokenId].speice = 3;
        } else if (_rand == 4) {
            _tokenIdToAttributes[_tokenId].speice = 4;
        } else if (_rand == 5) {
            _tokenIdToAttributes[_tokenId].speice = 5;
        }

        return _tokenIdToAttributes[_tokenId];
    }

    function randomUniqueNft() internal view returns (uint256) {
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(QRNG.getLatestRandom(), block.timestamp)
            )
        );
        return rand % 5;
    }

    function randRarity(uint256 _num) internal view returns (uint8) {
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.timestamp,
                    QRNG.getLatestRandom()
                )
            )
        ) % _num;
        return uint8(rand);
    }

    function selectAttrbiutes()
        internal
        view
        virtual
        returns (Attributes memory)
    {
        Attributes memory attr;

        attr.rarity = 1;
        attr.BaseTrait = randRarity(100) + 35;
        attr.MaxStamina = randRarity(15) + 35;
        attr.Stamina = randRarity(15) + 35;
        attr.Attack = randRarity(15) + 35;
        attr.MaxHealth = randRarity(15) + 35;
        attr.health = randRarity(15) + 35;
        attr.set = true;

        return attr;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721)
        returns (string memory)
    {
        return
            nftTokenURI(TokenUriAddress).getTokenURI(
                tokenId,
                _tokenIdToAttributes[tokenId],
                level[tokenId]
            );
    }
}
