// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Mint is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0 ether;
  uint256 public maxSupply = 10000;
  uint256 public maxMintAmount = 20;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply);

    if (msg.sender != owner()) {
      require(msg.value >= cost * _mintAmount);
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }
  
  function ERC721TokenIds(
    address user_,
    uint256 from_,
    uint256 to_
  ) public view returns (uint256[] memory ids, uint256 balance) {
    uint256 _to = to_;
    balance = balanceOf(user_);
    if (balance < _to) _to = balance;
    require(from_ < _to, 'index out of range');
    ids = new uint256[](_to - from_);
    for (uint256 i = 0; i < ids.length; i++) {
      ids[i] = tokenOfOwnerByIndex(user_, from_ + i);
    }
  }

    function ERC721TokenURIs(uint256[] calldata ids_) public view returns (string[] memory list) {
    list = new string[](ids_.length);
    for (uint256 i = 0; i < ids_.length; i++) {
      list[i] = tokenURI(ids_[i]);
    }
  }

    function ERC721TransferManyToOneAddress(
    address _address,
    uint256[] calldata _ids
  ) public {
    for (uint256 i = 0; i < _ids.length; i++) {
      safeTransferFrom(msg.sender, _address, _ids[i]);
    }
  }

    function ERC721TransferManyToManyAddresses(
    address _address,
    uint256[] calldata _ids
  ) public {
    for (uint256 i = 0; i < _ids.length; i++) {
      safeTransferFrom(msg.sender, _address, _ids[i]);
    }
  }
}