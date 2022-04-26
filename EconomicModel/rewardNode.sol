// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts-upgradeable/utils/StringsUpgradeable.sol";
import "../contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../contracts-upgradeable/proxy/utils/Initializable.sol";
import "../contracts-upgradeable/access/OwnableUpgradeable.sol";

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

contract Nodes is Initializable,OwnableUpgradeable {
    using StringsUpgradeable for uint256;
    using SafeMath for uint256;

    uint256 public _maxNodes;
    uint256 public _frequency;
    uint256 public _totalEnergy;
    uint256 public _proportion;
    uint256 public _mintRegistratPrice;
    uint256 public _initialEnergy;
    uint256 public _priceIncrease;
    uint256 public _quantitySold;

    bool public _isNodeSaleActive;
    bool public _isShareOutBonus;

    address public _pigStarAddress;
    address public _usdtAddress;
    address public _officialAccount;

    string purchaser = "purchaser";
    string business = "business";

    IERC20Upgradeable USDT;
    IERC20Upgradeable PIGSTAR;

    

    struct NodeItem {
        address owner;
        uint256 nodeAmount;
        uint256 totalEnergy;
        uint256 numberOfAwards;
        string purchaser;
    }

    NodeItem[] _nodeItems;
    mapping(address => uint256) _nodeItemIndex;

    function initialize () public initializer{
        __Context_init_unchained();
        __Ownable_init_unchained();
        _maxNodes = 300;
        _initialEnergy = 100;
        _frequency = 10;
        _totalEnergy = 0;
        _quantitySold = 0;
        _proportion = 618;
        _mintRegistratPrice = 1000 ether;
        _priceIncrease = 100 ether;
        _isNodeSaleActive = true;
        _isShareOutBonus = false;
        _pigStarAddress = 0xC58F5d1DE9742Aa7540024E2370A2B036C6Ef17a;
        // _usdtAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
        _usdtAddress = 0x714aBe1EDD6C157F4d92eC449bbC805a7bceeBef;
        USDT = IERC20Upgradeable (_usdtAddress);
        PIGSTAR = IERC20Upgradeable (0xC58F5d1DE9742Aa7540024E2370A2B036C6Ef17a);
        _officialAccount = 0xC58F5d1DE9742Aa7540024E2370A2B036C6Ef17a;
    }

    function saleRegistration() public returns(bool){
        require(_isNodeSaleActive, "The node sale is not start");
        require(_quantitySold < _maxNodes, "Registration quota is full");
        require(USDT.balanceOf(_msgSender()) >= _mintRegistratPrice, "Insufficient usdt balance");
        USDT.transferFrom(_msgSender(), address(this), _mintRegistratPrice);
        if(!isNodeExists(_msgSender())){
            createNodeItem(_msgSender(), purchaser);
        }
        //return registration(_msgSender());
        return true;
    }

    function businessRegistration(address businessRegistrar) public onlyOwner returns(bool){
        require(_quantitySold < _maxNodes, "Registration quota is full");
        require(businessRegistrar != address(0), "The registered address cannot be 0x0");
        if(!isNodeExists(businessRegistrar)){
            createNodeItem(businessRegistrar, business);
        }
        return registration(businessRegistrar);
    }

    function createNodeItem(address registrar, string memory registrarType) internal {
        _nodeItems.push(NodeItem(registrar,0,0,0,registrarType));
        _nodeItemIndex[registrar] = _nodeItems.length.sub(1);
    } 

    function registration(address registrar) internal returns(bool){
        if(_quantitySold != 0 && _quantitySold.mod(_frequency) == 0){
            setMintRegistratPrice(
                _mintRegistratPrice.add(_priceIncrease)
            );
        } 
        _quantitySold = _quantitySold.add(1);
        // NodeItem memory nodeItem = _nodeItems[_nodeItemIndex[registrar]];
        _nodeItems[_nodeItemIndex[registrar]].nodeAmount = _nodeItems[_nodeItemIndex[registrar]].nodeAmount.add(1);
        _nodeItems[_nodeItemIndex[registrar]].totalEnergy = _nodeItems[_nodeItemIndex[registrar]].totalEnergy.add(_initialEnergy);
        setTotalEnergy(_totalEnergy.add(_initialEnergy));
        return true;
    }

    function replaceNode(address displace, address to) public onlyOwner returns(bool){
        require(isNodeExists(displace), "The displace nodeItem does not exist");
        require(to != address(0), "The replace address cannot be 0x0");
        return replace(displace, to);
    }

    function replace(address displace, address to) internal returns(bool){
        NodeItem memory displaceItem = _nodeItems[_nodeItemIndex[displace]];
        if(_nodeItemIndex[to] == 0){
            createNodeItem(to, purchaser);
        }
        uint256 replaceEnergy = displaceItem.nodeAmount.mul(_initialEnergy);
        NodeItem memory toItem = _nodeItems[_nodeItemIndex[to]];
        toItem.nodeAmount = toItem.nodeAmount.add(displaceItem.nodeAmount);
        toItem.totalEnergy = toItem.totalEnergy.add(replaceEnergy);
        displaceItem.totalEnergy = displaceItem.totalEnergy.sub(replaceEnergy);
        displaceItem.nodeAmount = 0;
        return true;
    }

    function shareOutBonus() public onlyOwner {
        require(_isShareOutBonus, "Node rewards haven't started yet");
        require(_quantitySold >= 0, "No node exists");
        uint256 jackpot = USDT.balanceOf(address(this));
        uint256 disposableAmount = jackpot.mul(_proportion).div(1000);
        uint256 i;
        for (i = 0; i < _nodeItems.length; i++) {
            NodeItem memory nodeItem = _nodeItems[i];
            uint256 energyProportion = nodeItem.totalEnergy.div(_totalEnergy);
            uint256 sendValue = energyProportion.mul(disposableAmount);
            PIGSTAR.transfer(nodeItem.owner, sendValue);
            
        }
    }

    function isNodeExists(address owner) public view returns(bool){
        if (_nodeItems[_nodeItemIndex[owner]].owner != address(0)){
            return true;
        }
        return false;
    }

    function withdrawUSDT(address to) public onlyOwner {
        uint256 balance = USDT.balanceOf(address(this));
        USDT.transfer(to,balance);
    }

    function getNodeItem(address owner) public view returns(NodeItem memory) {
        return _nodeItems[_nodeItemIndex[owner]];
    } 

    function setMaxNodes(uint256 maxNodes) public onlyOwner {
        _maxNodes = maxNodes;
    }

    function setFrequency(uint256 frequency) public onlyOwner {
        _frequency = frequency;
    }

    function setTotalEnergy(uint256 totalEnergy) public onlyOwner {
        _totalEnergy = totalEnergy;
    }

    function setProportion(uint256 proportion) public onlyOwner {
        _proportion = proportion;
    }

    function setMintRegistratPrice(uint256 mintRegistratPrice) public onlyOwner {
        _mintRegistratPrice = mintRegistratPrice;
    }

    function setPriceIncrease(uint256 priceIncrease) public onlyOwner {
        _priceIncrease = priceIncrease;
    }

    function setInitialEnergy(uint256 initialEnergy) public onlyOwner {
        _initialEnergy = initialEnergy;
    }

    function setIsNodeSaleActive(bool isNodeSaleActive) public onlyOwner {
        _isNodeSaleActive = isNodeSaleActive;
    }

    function setIsShareOutBonus(bool isShareOutBonus) public onlyOwner {
        _isShareOutBonus = isShareOutBonus;
    }

    function setPigStarAddress(address pigStarAddress) public onlyOwner {
        _pigStarAddress = pigStarAddress;
        PIGSTAR = IERC20Upgradeable(_pigStarAddress);
    }

    function setUsdtAddress(address usdtAddress) public onlyOwner {
        _usdtAddress = usdtAddress;
        USDT =  IERC20Upgradeable(_usdtAddress);
    }

    function setOfficialAccount(address officialAccount) public onlyOwner {
        _officialAccount = officialAccount;
    }
}