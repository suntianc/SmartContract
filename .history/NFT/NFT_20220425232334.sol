// Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract PigStartNFT is Initializable, OwnableUpgradeable, ERC721EnumerableUpgradeable {
    using StringsUpgradeable for uint256;
    using SafeMath for uint256;
    // NFT
    uint256 public constant MAX_SUPPLY = 30900;
    uint256 public maxMint = 1;
    string public baseURI;
    string public baseExtension = ".json";
    //NFT ComputationalPower
    uint256 private S1 = 1200;
    uint256 private S2 = 720; 
    uint256 private S3 = 400; 
    uint256 private S4 = 200; 
    uint256 private S5 = 150; 
    uint256 private S6 = 120; 
    uint256 private SY = 720;
    //Sale
    uint256 public saleItems;
    struct SaleItem {
        uint256 itemId;
        uint256 surplus;
        uint256 mintPrice;
        uint256 saleAmount;
        bool isSaleActive;
        bool isSoldOut;
        bool isUse;
    }
    mapping(uint256 => SaleItem) idToSaleItem;

    mapping(uint256 => string) private _tokenURIs;
    uint256 constant private TOKEN_LIMIT = 30001;
    uint256[TOKEN_LIMIT] private indices;
    uint256 private nonce;

    event MarketItemCreated (
        uint256 indexed itemId,
        uint256 surplus,
        uint256 mintPrice,
        uint256 saleAmount,
        bool isSaleActive,
        bool isSoldOut,
        bool isUse
    );

    function initialize (string memory initBaseURI) public initializer{
        __Context_init_unchained();
        __Ownable_init_unchained();
        __ERC721_init("PigStart NFT", "PSN");
        setBaseURI(initBaseURI);
    }

    function startSale(uint256 itemId) public onlyOwner {
        require(
            idToSaleItem[itemId].surplus != 0,
            "This activity blind box is sold out"
        );
        idToSaleItem[itemId].isSaleActive = true;
    }

    function createSaleItem(uint256 itemId, uint256 saleAmount, uint256 mintPrice) public onlyOwner {
        _createSaleItem(itemId, saleAmount, mintPrice);
    }

    function _createSaleItem(uint256 itemId, uint256 saleAmount, uint256 mintPrice) internal {
        idToSaleItem[itemId] = SaleItem(itemId,saleAmount,mintPrice,saleAmount,false, false, true);
        emit MarketItemCreated(
            itemId,
            saleAmount,
            mintPrice,
            saleAmount,
            false,
            false,
            true
        );
        saleItems = saleItems.add(1);
    }

    function querySaleMsg(uint256 itemId) public view returns(SaleItem memory){
        return idToSaleItem[itemId];
    }

    function salePigStarNFT(uint256 saleIndex) public payable {
        require(
            idToSaleItem[saleIndex].isUse,
            "This sale does not exist"
        );
        require(
            idToSaleItem[saleIndex].isSaleActive,
            "This sale has not started"
        );
        require(
            !idToSaleItem[saleIndex].isSoldOut,
            "This activity blind box is sold out"
        );
        require(
            totalSupply() <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(
            idToSaleItem[saleIndex].mintPrice <= msg.value,
            "Not enough ether sent"
        );
        _mintPigStarNFT(maxMint);
        if(idToSaleItem[saleIndex].surplus.sub(maxMint) == 0){
            idToSaleItem[saleIndex].surplus = 0;
            idToSaleItem[saleIndex].isSoldOut = true;
        }else{
            idToSaleItem[saleIndex].surplus = idToSaleItem[saleIndex].surplus.sub(maxMint);
        }
    }

    function _mintPigStarNFT(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex()-1);
            }
        }
    }

    function mintIndex() public returns (uint256) {
        uint256 totalSize = TOKEN_LIMIT - nonce;
        uint256 index = uint256(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % totalSize;
        uint256 value = 0;
        if (indices[index] != 0) {
            value = indices[index];
        } else {
            value = index;
        }
        // Move last value to selected position
        if (indices[totalSize - 1] == 0) {
            // Array position not initialized, so use position
            indices[index] = totalSize - 1;
        } else {
            // Array position holds a value so use that
            indices[index] = indices[totalSize - 1];
        }
        nonce++;
        // Don't allow a zero index, start counting at 1
        return value+1;
    }

    function computationalPower (uint256 tokenId) public view returns(uint256){
        require(tokenId > 30900, "Tokenid does not exist");
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

    function setMintPrice(uint256 saleIndex,uint256 _mintPrice) public onlyOwner {
        idToSaleItem[saleIndex].mintPrice = _mintPrice;
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

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}