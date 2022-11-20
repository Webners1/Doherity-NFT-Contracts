

            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
// import "@openzeppelin/contracts/utils/Strings.sol";
pragma solidity ^0.8.1;

//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";
library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

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
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
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
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
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
interface nftTokenURI{
    
    function getTokenURI(uint256 _tokenId,Attributes memory NFTData, uint level) external view returns (string memory);
  }
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AaronNFT is ERC721, Ownable {
    uint256 public tokenIds;


    // Rarity Classes
    enum Class {
    Common,
    Uncommon,
    Rare,
    Legendary
  }
    uint256 public price = 0.5 ether;
  
    address TokenUriAddress;
    uint public _seed;

    
    
    // Starts From 0
  

address private _burnAddress;
uint256 public random;
 constructor(address _TokenUriAddress,uint256 _random)ERC721("MyToken", "MTK"){
   
   TokenUriAddress= _TokenUriAddress;
     
    _burnAddress = 0x000000000000000000000000000000000000dEaD;
    // Starts From 0
     random = _random;
    }
    


    struct EggHatch {
        uint hatchTime;
        bool hasAlreadyHatched;
        bool isHatching;
    }

    mapping(uint=>Attributes) public _tokenIdToAttributes;
    mapping(uint=>EggHatch) public _eggHatch;
    

    // baby.mature,max mature bird level
    mapping(uint=>uint8) public level;
    mapping(uint=>uint) public _rewardTime;

    event EggMinted(address indexed, uint indexed);
    event EggLocked(uint indexed, uint indexed);
    event EggRarity(uint indexed, uint indexed);


   



    function getRarity(uint _tokenId) external virtual view returns(string memory) {
        require(level[_tokenId] > 0, "not hatched yet");
        uint8 rar = _tokenIdToAttributes[_tokenId].rarity;
        if(rar == 0) {
            return "Common";
        } else if(rar == 1) {
            return "UnCommon";
        } else if(rar == 2) {
            return "Rare";
        } else if(rar == 3) {
            return "Legendary";
        }
        return "Common";
    } 

  
    
   

  
     function setSeed(uint _s) external onlyOwner {
        _seed = _s;
    } 


    function mintEgg(uint tNumber,address account)
        external
        payable
        onlyOwner
    {
        require(msg.value >= price*tNumber,"Price is low");
        for(uint i = 0; i<tNumber; i++) {

             uint256 newItemId = tokenIds++;
            _mint(account, newItemId);

            level[newItemId] = 1;
        }
       emit EggMinted(account, tNumber);
    }


    function lockInIncubator(uint _tokenId) public virtual {
        require(ownerOf(_tokenId) == msg.sender, "Not Owner");
        require(_eggHatch[_tokenId].hasAlreadyHatched == false, "already hatched");

        _eggHatch[_tokenId].isHatching = true;
       
        _eggHatch[_tokenId].hatchTime = block.timestamp + 7 days;
        emit EggLocked(_tokenId, _eggHatch[_tokenId].hatchTime);
    }
    
    function changeEveryNFTRemainingTime(uint hatchTime) public onlyOwner{
        for(uint i=0;i<= tokenIds;i++){
        _eggHatch[i].hatchTime = block.timestamp + hatchTime;

        }
    }
function changeHatchTime(uint _tokenId, uint hatchTime)public virtual onlyOwner{
        require(_eggHatch[_tokenId].hasAlreadyHatched == false, "already hatched");

        _eggHatch[_tokenId].hatchTime = block.timestamp + hatchTime;
}
    function hatchRemainingTime(uint _tokenId) public view returns(uint) {
       
         if(_eggHatch[_tokenId].hatchTime <= block.timestamp) {
             return 0;
         }
         uint remainTime = _eggHatch[_tokenId].hatchTime - block.timestamp;
         return remainTime;
    }

    function hatchEgg(uint _tokenId) public {
     
    _eggHatch[_tokenId].isHatching = false;

    level[_tokenId] = 1;

    _tokenIdToAttributes[_tokenId] = selectAttrbiutes();
    selectRandomNftWithAttributes(_tokenId);
    emit EggRarity(_tokenId, _tokenIdToAttributes[_tokenId].rarity);
    }

    function selectRandomNftWithAttributes(uint _tokenId) internal returns(Attributes memory) {
        uint _rand = randomUniqueNft();
        if(_rand == 0) {
            _tokenIdToAttributes[_tokenId].uniqueAttribute = "Powerful Sharp Feet";
            _tokenIdToAttributes[_tokenId].speice = 0;
        } else if(_rand == 1) {
            _tokenIdToAttributes[_tokenId].uniqueAttribute = "Powerful Beak";
            _tokenIdToAttributes[_tokenId].speice = 1;
        } else if(_rand == 2) {
            _tokenIdToAttributes[_tokenId].uniqueAttribute = "Speed";
            _tokenIdToAttributes[_tokenId].speice = 2;
        } else if(_rand == 3) {
            _tokenIdToAttributes[_tokenId].uniqueAttribute = "Camoflauge";
            _tokenIdToAttributes[_tokenId].speice = 3;
        } else if(_rand == 4) {
            _tokenIdToAttributes[_tokenId].uniqueAttribute = "Strength";
            _tokenIdToAttributes[_tokenId].speice = 4;
        } else if(_rand == 5) {
            _tokenIdToAttributes[_tokenId].uniqueAttribute = "Intelligence";
            _tokenIdToAttributes[_tokenId].speice = 5;
        } 

        return _tokenIdToAttributes[_tokenId];
    }

     function randomUniqueNft() internal view returns (uint) {
        uint rand =  uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _seed,
        random)));
        return rand % 8;
    }

    function randRarity(uint _randomNum, uint _num) internal view returns(uint8) {
         uint rand =  uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _seed, _randomNum))) % _num;
         return uint8(rand);
    }


    function randomNumProb() internal view returns(Class) {
        uint rand =  uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _seed,random))) % 100;
        uint[] memory _classProbabilities = new uint[](8);
        _classProbabilities[0] = 68;
        _classProbabilities[1] = 20;
        _classProbabilities[2] = 10;
        _classProbabilities[3] = 2;
        _classProbabilities[4] = 2;
        _classProbabilities[5] = 2;
        _classProbabilities[6] = 2;
        _classProbabilities[7] = 2;
        
         // Start at top class (length - 1)
        // skip common (0), we default to it{
        if(tokenIds <=20){
        return Class.Legendary; 
        }
        else{
        for (uint i = _classProbabilities.length - 1; i > 0; i--) {
            uint probability = _classProbabilities[i];
            if(rand < probability) {
                return Class(i);
            } else {
                rand = rand - probability;
            }
        }

        return Class.Common; 
        }
    }

    function selectAttrbiutes() internal virtual view returns(Attributes memory){
        Attributes memory attr;
        
            
            attr.rarity = 1;
           attr.BaseTrait = randRarity(230, 15) + 35;
            attr.MaxStamina = randRarity(10230, 15) + 35;
            attr.Stamina = randRarity(12200, 15) + 35;
            attr.Attack = randRarity(10560, 15) + 35;
            attr.MaxHealth = randRarity(10740, 15) + 35;
            attr.health = randRarity(10450, 15) + 35;
            attr.set = true;
           

       
return attr;
    }
      function getTokenURI( uint tokenId,Attributes memory NFTData,uint level) public (nftTokenURI)  view  returns (string memory) {
    string memory _eggUri = "https://astrobirdz.mypinata.cloud/ipfs/QmVWCtAxaRVktazv4JddXMhMZYAUNRWrvZoDGQhmuy64Hp/video_2022-04-15_14-40-52.mp4";
string memory json;
         if(NFTData.set == false) {
             json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    "{'name': '", Strings.toString(tokenId), "',",
                    "'image_data': '", _eggUri, "',",
                    "'description': '", "An Egg'",
                    "}"   
                )
            ))
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
        }

         string memory uri;

         if(level == 1) {
             if(NFTData.speice == 0) {
                 uri = "https://astrobirdz.mypinata.cloud/ipfs/QmVWCtAxaRVktazv4JddXMhMZYAUNRWrvZoDGQhmuy64Hp/baby-eagle-complete.mp4";
             } else if(NFTData.speice == 1) {
                 uri = "https://astrobirdz.mypinata.cloud/ipfs/QmVWCtAxaRVktazv4JddXMhMZYAUNRWrvZoDGQhmuy64Hp/Baby%20-%20Cockatiel.mp4";
             } else if(NFTData.speice == 2) {
                 uri = "https://astrobirdz.mypinata.cloud/ipfs/QmVWCtAxaRVktazv4JddXMhMZYAUNRWrvZoDGQhmuy64Hp/Baby%20-%20Sparrow.mp4";
             } else if(NFTData.speice == 3) {
                 uri = "https://astrobirdz.mypinata.cloud/ipfs/QmVWCtAxaRVktazv4JddXMhMZYAUNRWrvZoDGQhmuy64Hp/Baby%20-%20Cardinal.mp4";
             } else if(NFTData.speice == 4) {
                 uri = "https://astrobirdz.mypinata.cloud/ipfs/QmVWCtAxaRVktazv4JddXMhMZYAUNRWrvZoDGQhmuy64Hp/Baby%20-%20Vulture.mp4";
             } else if(NFTData.speice == 5) {
                 uri = "https://astrobirdz.mypinata.cloud/ipfs/QmVWCtAxaRVktazv4JddXMhMZYAUNRWrvZoDGQhmuy64Hp/Baby%20-%20Swan.mp4";
             }
             else if(NFTData.speice == 6) {
                 uri = "https://astrobirdz.mypinata.cloud/ipfs/QmVWCtAxaRVktazv4JddXMhMZYAUNRWrvZoDGQhmuy64Hp/Baby%20-%20Swan.mp4";
             }
             else if(NFTData.speice == 7) {
                 uri = "https://astrobirdz.mypinata.cloud/ipfs/QmVWCtAxaRVktazv4JddXMhMZYAUNRWrvZoDGQhmuy64Hp/Baby%20-%20Swan.mp4";
             }
         } 
    
        json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    "{'name': '", Strings.toString(tokenId), "',",
                    "'image_data': '", uri, "',",
                    // "'description': '", "Bird'", ",",
                    "'attributes': [{'trait_type': 'Base Trait', 'value': '", NFTData.BaseTrait, "'},",
                    "{'trait_type': 'Attribute', 'value': '", NFTData.uniqueAttribute, "'},",
                    "{'trait_type': 'Max Stamina', 'value': '", Strings.toString(NFTData.MaxStamina), "'},",
                    "{'trait_type': 'Level', 'value': '", Strings.toString(NFTData.Level), "'},",
                    "{'trait_type': 'Rarity', 'value': '", Strings.toString(NFTData.rarity), "'},",
                    "{'trait_type': 'Stamina', 'value': '", Strings.toString(NFTData.Stamina), "'},",
                    "{'trait_type': 'Attack Power', 'value': '", Strings.toString(NFTData.Attack), "'},",
                    "{'trait_type': 'Max Health Points', 'value': '", Strings.toString(NFTData.MaxHealth), "'},",
                    "{'trait_type': 'Health Points', 'value': '", Strings.toString(NFTData.health), "'}",
                    "]}"
                    
                )
            ))
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
     }
     function tokenURI(uint256 tokenId) override(ERC721) public virtual view returns (string memory) {

     return getTokenURI(tokenId,_tokenIdToAttributes[tokenId],level[tokenId]);
     }

}
