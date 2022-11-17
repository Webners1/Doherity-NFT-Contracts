

            
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
 constructor(address _TokenUriAddress)ERC721("MyToken", "MTK"){
   
   TokenUriAddress= _TokenUriAddress;
     
    _burnAddress = 0x000000000000000000000000000000000000dEaD;
    // Starts From 0
     
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
        uint rand =  uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _seed)));
        return rand % 8;
    }

    function randRarity(uint _randomNum, uint _num) internal view returns(uint8) {
         uint rand =  uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _seed, _randomNum))) % _num;
         return uint8(rand);
    }


    function randomNumProb() internal view returns(Class) {
        uint rand =  uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _seed))) % 100;
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
     function tokenURI(uint256 tokenId) override(ERC721) public virtual view returns (string memory) {

     return nftTokenURI(TokenUriAddress).getTokenURI(tokenId,_tokenIdToAttributes[tokenId],level[tokenId]);
     }
}
