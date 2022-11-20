

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
     

       }

