// Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

contract NicMeta is Initializable, OwnableUpgradeable, ERC721EnumerableUpgradeable {
    using StringsUpgradeable for uint256;

    bool public _isSaleActive = false;
    bool public _revealed = false;

    // Constants
    uint256 public constant MAX_SUPPLY = 30900;
    uint256 public surplus = 300;
    uint256 public mintPrice = 0.3 ether;
    uint256 public maxBalance = 1;
    uint256 public maxMint = 1;
    //ComputationalPower
    uint256 public S1 = 1200;
    uint256 public S2 = 720; 
    uint256 public S3 = 400; 
    uint256 public S4 = 200; 
    uint256 public S5 = 150; 
    uint256 public S6 = 120; 
    uint256 public SY = 720;

    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) private _tokenIdIndex;

    function initialize (string memory initBaseURI, string memory initNotRevealedUri) public initializer{
        __Context_init_unchained();
        __Ownable_init_unchained();
        __ERC721_init("Nic Meta", "NM");
        setBaseURI(initBaseURI);
        setNotRevealedURI(initNotRevealedUri);
        uint256 i;
        for(i = 0; i < MAX_SUPPLY; i++){
            _tokenIdIndex[i] = i;
        }
    }

    function mintNicMeta(uint256 tokenQuantity) public payable {
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(_isSaleActive, "Sale must be active to mint NicMetas");
        require(
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether sent"
        );
        require(tokenQuantity <= maxMint, "Can only mint 1 tokens at a time");

        _mintNicMeta(tokenQuantity);
    }

    function _mintNicMeta(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
            uint256 mintIndex = random%surplus;
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
                delete _tokenIdIndex[mintIndex];
                surplus--;
            }
        }
    }

    function computationalPower (uint256 tokenId) public view returns(uint256){
        require(tokenId > 30900, "Tokenid does not exist");
        require(_tokenIdIndex[tokenId] == 0, "The NFT of this tokenId has not been produced yet");
        if(tokenId >=0 && tokenId < 300){
            return S1;
        }
        else if(tokenId >= 300 && tokenId < 1200){
            return S2;
        }
        else if(tokenId >= 1200 && tokenId < 3600){
            return S3;
        }
        else if(tokenId >= 3600 && tokenId < 9000){
            return S4;
        }
        else if(tokenId >= 9000 && tokenId < 18000){
            return S5;
        }
        else if(tokenId >= 18000 && tokenId < 30000){
            return S6;
        }
        else if(tokenId >= 30000 && tokenId < 30900){
            return SY;
        }
        return 0;
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

        if (_revealed == false) {
            return notRevealedUri;
        }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}