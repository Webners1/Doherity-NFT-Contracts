import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library Base64 {
    string internal constant TABLE_ENCODE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    bytes internal constant TABLE_DECODE =
        hex"0000000000000000000000000000000000000000000000000000000000000000"
        hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
        hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
        hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(18, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(12, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(6, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                // read 4 characters
                dataPtr := add(dataPtr, 4)
                let input := mload(dataPtr)

                // write 3 bytes
                let output := add(
                    add(
                        shl(
                            18,
                            and(
                                mload(add(tablePtr, and(shr(24, input), 0xFF))),
                                0xFF
                            )
                        ),
                        shl(
                            12,
                            and(
                                mload(add(tablePtr, and(shr(16, input), 0xFF))),
                                0xFF
                            )
                        )
                    ),
                    add(
                        shl(
                            6,
                            and(
                                mload(add(tablePtr, and(shr(8, input), 0xFF))),
                                0xFF
                            )
                        ),
                        and(mload(add(tablePtr, and(input, 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}

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
    constructor(address _airnodeRrp, address _NFTContract)
        RrpRequesterV0(_airnodeRrp)
    {
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
    uint8 ExperiencePoint;
    uint8 rarity;
    string BaseTrait;
    uint256 MaxStamina;
    uint256 Stamina;
    uint256 Attack;
    uint8 MaxHealth;
    uint256 Defense;
    uint8 health;
    uint8 Level;
    //check if attributes are setted
    bool set;
}

contract AaronNFT is ERC721,AccessControl {
    uint256 public tokenIds;
     bytes32 public constant NFT_EDITOR_ROLE = keccak256("NFT_EDITOR_ROLE");
    // Rarity Classes
    uint256 public price = 0.5 ether;

    mapping(uint256 => Attributes) public _tokenIdToAttributes;
    // Starts From 0
    string public notRevealedUri;
    address private _burnAddress;
    QrngRandom public QRNG;
    mapping(uint256 => uint256) public NFTBatch;

    constructor(address qrngRandom, string memory _initNotRevealedUri,address StakingContract)
        ERC721("MyToken", "MTK")
    {
        QRNG = QrngRandom(qrngRandom);
        // Starts From 0
        notRevealedUri = _initNotRevealedUri;
        NFTBatch[0] = 1000;
        NFTBatch[1] = 500;
        NFTBatch[2] = 375;
        NFTBatch[3] = 250;
        NFTBatch[4] = 175;
        NFTBatch[5] = 125;
        NFTBatch[6] = 50;
        NFTBatch[7] = 25;
          _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    function grantNFTRole(address _NFT_EDITOR_ROLE)public onlyRole(DEFAULT_ADMIN_ROLE){
        _grantRole(NFT_EDITOR_ROLE,_NFT_EDITOR_ROLE);
    }
    // baby.mature,max mature bird level
    mapping(uint256 => uint8) public level;
    bool public revealed = false;
    event Minted(address indexed, uint256 indexed);
    event Rarity(uint256 indexed, uint256 indexed);

    function mint(uint256 tNumber, address account) external payable onlyRole(DEFAULT_ADMIN_ROLE) {
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
        uint256 _rand = randomNumProb();
        _tokenIdToAttributes[_tokenId].speice = uint8(_rand);
        return _tokenIdToAttributes[_tokenId];
    }

     function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function updateTraits(uint256 tokenId,
    uint8 ExperiencePoint,
    uint8 rarity,
    uint256 Stamina,
    uint256 Attack,
    uint8 MaxHealth,
    uint256 Defense,
    uint8 health,
    uint8 Level) public onlyRole(NFT_EDITOR_ROLE) {
        
    _tokenIdToAttributes[tokenId].ExperiencePoint = ExperiencePoint;
    _tokenIdToAttributes[tokenId].rarity = rarity;
    _tokenIdToAttributes[tokenId].Stamina = Stamina;
    _tokenIdToAttributes[tokenId].Attack = Attack;
    _tokenIdToAttributes[tokenId].MaxHealth = MaxHealth;
    _tokenIdToAttributes[tokenId].Defense = Defense;
    _tokenIdToAttributes[tokenId].health = health;
    _tokenIdToAttributes[tokenId].Level = Level;
           }

    function randomUniqueNft() internal view returns (uint256) {
        uint256 rand = uint256(
            keccak256(abi.encodePacked(QRNG.getLatestRandom(), block.timestamp))
        );
        return rand % 7;
    }

    function randomNumProb() internal returns (uint256) {
        uint256 rand = randRarity(2500);
        uint256[] memory _classProbabilities = new uint256[](8);
        _classProbabilities[0] = NFTBatch[0];
        _classProbabilities[1] = NFTBatch[1];
        _classProbabilities[2] = NFTBatch[2];
        _classProbabilities[2] = NFTBatch[3];
        _classProbabilities[4] = NFTBatch[4];
        _classProbabilities[5] = NFTBatch[5];
        _classProbabilities[6] = NFTBatch[6];
        _classProbabilities[7] = NFTBatch[7];

        // Start at top class (length - 1)
        // skip common (0), we default to it{

        for (uint256 i = _classProbabilities.length - 1; i > 0; i--) {
            uint256 probability = _classProbabilities[i];
            if (rand < probability) {
                NFTBatch[i] = NFTBatch[i] - 1;
                return i;
            } else {
                rand = rand - probability;
            }
        }
        NFTBatch[0] = NFTBatch[0] - 1;
        if (NFTBatch[0] > 0) {
            return 0;
        } else {
            for (uint256 index; index < 8; index++) {
                if (NFTBatch[index] > 0) {
                    return index;
                }
            }
        }
    }

    function randRarity(uint256 _num) internal view returns (uint256) {
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.timestamp,
                    QRNG.getLatestRandom()
                )
            )
        ) % _num;
        return rand;
    }

    function reveal() public onlyRole(DEFAULT_ADMIN_ROLE) {
        revealed = true;
    }

    function selectAttrbiutes()
        internal
        view
        virtual
        returns (Attributes memory)
    {
        Attributes memory attr;

        attr.rarity = 5;
        attr.BaseTrait = "Anomaly";
        attr.ExperiencePoint = 0;
        attr.MaxStamina = 300;
        attr.Stamina = 300;
        attr.Attack = randRarity(100) + 350;
        attr.Defense = randRarity(100) + 350;
        attr.MaxHealth = 100;
        attr.health = 100;
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
        if (revealed == false) {
            return notRevealedUri;
        }
        return
            getTokenURI(tokenId, _tokenIdToAttributes[tokenId], level[tokenId]);
    }

    function getTokenURI(
        uint256 tokenId,
        Attributes memory NFTData,
        uint256 level
    ) public view returns (string memory) {
        string memory json;

        string memory uri;

        if (level == 1) {
            if (NFTData.speice == 0) {
                uri = "";
            } else if (NFTData.speice == 1) {
                uri = "";
            } else if (NFTData.speice == 2) {
                uri = "";
            } else if (NFTData.speice == 3) {
                uri = "";
            } else if (NFTData.speice == 4) {
                uri = "";
            } else if (NFTData.speice == 5) {
                uri = "";
            } else if (NFTData.speice == 6) {
                uri = "";
            } else if (NFTData.speice == 7) {
                uri = "";
            }
        }

        json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        "{'name': '",
                        Strings.toString(tokenId),
                        "',",
                        "'image_data': '",
                        uri,
                        "',",
                        // "'description': '", "Bird'", ",",
                        "'attributes': [{'trait_type': 'Base Trait', 'value': '",
                        NFTData.BaseTrait,
                        "'},",
                        "{'trait_type': 'Experience Points', 'value': '",
                        Strings.toString(NFTData.ExperiencePoint),
                        "'},",
                        "{'trait_type': 'Max Stamina', 'value': '",
                        Strings.toString(NFTData.MaxStamina),
                        "'},",
                        "{'trait_type': 'Level', 'value': '",
                        Strings.toString(NFTData.Level),
                        "'},",
                        "{'trait_type': 'Rarity', 'value': '",
                        Strings.toString(NFTData.rarity),
                        "'},",
                        "{'trait_type': 'Stamina', 'value': '",
                        Strings.toString(NFTData.Stamina),
                        "'},",
                        "{'trait_type': 'Attack Power', 'value': '",
                        Strings.toString(NFTData.Attack),
                        "'},",
                        "{'trait_type': 'Defense Points', 'value': '",
                        Strings.toString(NFTData.Defense),
                        "'},",
                        "{'trait_type': 'Max Health Points', 'value': '",
                        Strings.toString(NFTData.MaxHealth),
                        "'},",
                        "{'trait_type': 'Health Points', 'value': '",
                        Strings.toString(NFTData.health),
                        "'}",
                        "]}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
