// SPDX-License-Identifier: MIT
// SettleMint.com

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./library/token/ERC721/extensions/ERC721Freezable.sol";
import "./library/token/ERC721/extensions/ERC721MintPausable.sol";
import "./interfaces/IERC5192.sol";

contract SoulboundToken is
  ERC721Enumerable,
  ERC721Burnable,
  ERC721Pausable,
  ERC721Freezable,
  ERC721MintPausable,
  Ownable,
  ReentrancyGuard
{

  //////////////////////////////////////////////////////////////////
  // TOKEN STORAGE                                                //
  //////////////////////////////////////////////////////////////////

  uint256 private _tokenId;
  string private _baseTokenURI; // the IPFS url to the folder holding the metadata.

  //////////////////////////////////////////////////////////////////
  // SBT STORAGE                                            //
  //////////////////////////////////////////////////////////////////

  mapping(address => uint256) private _addressToMinted; // the amount of tokens an address has minted
  mapping(uint256 => bool) public _locked; // mapping of tokenId to the locked status

  modifier IsTransferAllowed(uint256 tokenId) {
      require(!_locked[tokenId], "The locked SBT cannot be transferred.");
      _;
  }

  constructor(
    string memory name_,
    string memory symbol_,
    string memory baseTokenURI_
  ) ERC721(name_, symbol_) {
    _baseTokenURI = baseTokenURI_;
  }

  /// @notice Emitted when the locking status is changed to locked.
  /// @dev If a token is minted and the status is locked, this event should be emitted.
  /// @param tokenId The identifier for a token.
  event Locked(uint256 tokenId);

  /// @notice Emitted when the locking status is changed to unlocked.
  /// @notice currently SBT Contract does not emit Unlocked event
  /// @dev If a token is minted and the status is unlocked, this event should be emitted.
  /// @param tokenId The identifier for a token.
  event Unlocked(uint256 tokenId);


  //////////////////////////////////////////////////////////////////
  // CORE FUNCTIONS                                               //
  //////////////////////////////////////////////////////////////////

  function setBaseURI(string memory baseTokenURI_) public onlyOwner whenURINotFrozen {
    _baseTokenURI = baseTokenURI_;
  }

  function _baseURI() internal view override returns (string memory) {
    return _baseTokenURI;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    string memory tokenUri = super.tokenURI(tokenId);
    return bytes(tokenUri).length > 0 ? string(abi.encodePacked(tokenUri, ".json")) : "";
  }

  function safeMint(address to, uint256 tokenId) public onlyOwner {
      require(balanceOf(to) == 0, "SBT: Only one SBT per account.");
      require(_locked[tokenId] != true, "SBT: The SBT is already locked.");

      _locked[tokenId] = true;
      emit Locked(tokenId);

      _safeMint(to, tokenId);
  }

  function safeTransferFrom(
      address from,
      address to,
      uint256 tokenId
  ) public virtual override(IERC721, ERC721) IsTransferAllowed(tokenId) {
      super.safeTransferFrom(from, to, tokenId);
  }

  function safeTransferFrom(
      address from,
      address to,
      uint256 tokenId,
      bytes memory data
  ) public virtual override(IERC721, ERC721) IsTransferAllowed(tokenId) {
      super.safeTransferFrom(from, to, tokenId, data);
  }

  function transferFrom(
      address from,
      address to,
      uint256 tokenId
  ) public virtual override(IERC721, ERC721) IsTransferAllowed(tokenId) {
      super.safeTransferFrom(from, to, tokenId);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal override(ERC721, ERC721Enumerable, ERC721Pausable, ERC721MintPausable) {
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal override(ERC721, ERC721Freezable) {
    super._afterTokenTransfer(from, to, tokenId, batchSize);
  }

  /// @notice Returns the locking status of an Soulbound Token
  /// @dev SBTs assigned to zero address are considered invalid, and queries
  /// about them do throw.
  /// @param tokenId The identifier for an SBT.
  function locked(uint256 tokenId) external view returns (bool) {
      require(ownerOf(tokenId) != address(0), "The address cannot be 0x.");
      return _locked[tokenId];
  }

  //////////////////////////////////////////////////////////////////
  // POST TRANSFER MANAGEMENT                                         //
  //////////////////////////////////////////////////////////////////

  function _burn(uint256 tokenId) internal override(ERC721) {
    super._burn(tokenId);
  }

  function burn(uint256 tokenId) public override {
    require(msg.sender == ownerOf(tokenId), "Only the owner of SBT can burn it.");

    _burn(tokenId);
  }

  function freeze() external onlyOwner {
    super._freeze();
  }


  //////////////////////////////////////////////////////////////////
  // Pausable & MintPausable                                      //
  //////////////////////////////////////////////////////////////////

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function pauseMint() public onlyOwner {
    _pauseMint();
  }

  function unpauseMint() public onlyOwner {
    _unpauseMint();
  }

  //////////////////////////////////////////////////////////////////
  // ERC165                                                       //
  //////////////////////////////////////////////////////////////////

  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
    return
      interfaceId == type(Ownable).interfaceId ||
      interfaceId == type(ERC721Burnable).interfaceId ||
      interfaceId == type(ERC721Enumerable).interfaceId ||
      interfaceId == type(ERC721Freezable).interfaceId ||
      interfaceId == type(ERC721MintPausable).interfaceId ||
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC5192).interfaceId ||
      super.supportsInterface(interfaceId);
  }
}
