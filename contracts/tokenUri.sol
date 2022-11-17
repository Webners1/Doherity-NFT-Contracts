
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


pragma solidity ^0.8.1;
interface nftTokenURI{
     struct Attributes {
        string uniqueAttribute;
        uint8 speice;
        uint8 rarity;
        string BaseTrait;
        uint8 MaxStamina;
        uint8 Stamina;
        uint8 Attack;
        uint8 MaxHealth;
        uint8 health;
        uint8 Level;
        //check if attributes are setted
        bool set;
    }
    function getTokenURI(uint256 _tokenId,Attributes memory NFTData, uint level) external view returns (string memory);
  }
contract tokenURI is nftTokenURI{
       
constructor(){}
       function getTokenURI( uint tokenId,Attributes memory NFTData,uint level) public override(nftTokenURI)  view  returns (string memory) {
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

       }

