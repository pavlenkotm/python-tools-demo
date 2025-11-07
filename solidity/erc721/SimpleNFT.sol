// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title SimpleNFT
 * @dev ERC721 NFT with URI storage and minting capability
 */
contract SimpleNFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public maxSupply;
    uint256 public mintPrice;

    event NFTMinted(address indexed to, uint256 indexed tokenId, string tokenURI);

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        uint256 _mintPrice
    ) ERC721(name, symbol) Ownable(msg.sender) {
        maxSupply = _maxSupply;
        mintPrice = _mintPrice;
    }

    /**
     * @dev Mint a new NFT
     */
    function mint(address to, string memory uri) public payable returns (uint256) {
        require(_tokenIds.current() < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, uri);

        emit NFTMinted(to, newTokenId, uri);

        return newTokenId;
    }

    /**
     * @dev Owner can mint for free
     */
    function ownerMint(address to, string memory uri) public onlyOwner returns (uint256) {
        require(_tokenIds.current() < maxSupply, "Max supply reached");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, uri);

        emit NFTMinted(to, newTokenId, uri);

        return newTokenId;
    }

    /**
     * @dev Withdraw contract balance
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    /**
     * @dev Update mint price
     */
    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }

    /**
     * @dev Get total minted
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    // Required overrides
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
