pragma solidity >=0.5.0 <0.6.0;


interface ERC20 {

function parents(address _owner) external view returns (address Agent);
function getchildslength(address _owner) external view returns (uint balance);
function balanceOf(address _owner) external view returns (uint balance);
function transfer(address _to, uint _value) external returns (bool success);
function transferFrom(address _from, address _to, uint _value) external returns (bool success);
function approve(address _spender, uint _value) external returns (bool success);
function allowance(address _owner, address _spender) external view returns (uint remaining);
function mint(address _owner)external;

}
interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IUniswapV2Pair {

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

}
interface IRouter{
       function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
         function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
contract tran{

address public F;




address public usdt_address=0x5efA26581e1F1eACA8bBF957821174dcCd88ebF9;

address public tokenaddress=0x6B2d313e230e1fd725b18aF5Ff417AF9CB3C2AA3;

address public owner; //拥有者地址
uint256 public min_number = 1;//最小认购数量



mapping(address => uint256)public Mymoney;
mapping(address => uint256)public Myvalue;

mapping(address => address)public agent;
address public receiveAddress;
uint256 public tokenamount = 2*10**18;
mapping(address => uint256)public is_withdraw;
uint256 public withdraw = 0;
mapping(address => uint256) public mytoken;
event WithDraw(address indexed _from, address indexed _to,uint256 _value);
constructor() public {
owner = msg.sender;

    receiveAddress= msg.sender;

}

modifier onlyOwner() {
require(msg.sender == owner);
_;
}


function infos(address _address)public view returns(uint256,uint256,uint256,uint256,uint256){
   return(ERC20(usdt_address).balanceOf(_address),
   ERC20(usdt_address).allowance(_address,address(this)),
   Mymoney[_address],
   withdraw,

   mytoken[_address]
   );
}


function _buy(uint256 _value)public  returns(bool) {

    uint256 amount = _value;
     require(amount >= min_number );
  
    ERC20(usdt_address).transferFrom(msg.sender,address(this),amount);
    uint256 fee = 0;

     ERC20(usdt_address).transfer(receiveAddress,amount-fee);
   
   
    Mymoney[msg.sender] += amount; 
  mytoken[msg.sender]+= Mymoney[msg.sender]*tokenamount/1e18;



}
function claim()public{
     require(withdraw == 1);
     require(mytoken[msg.sender] > 0);
  
    
      ERC20(tokenaddress).transfer(msg.sender, mytoken[msg.sender]);
       mytoken[msg.sender] = 0;
    
}

 
function setReceive(address _receive) onlyOwner public returns(bool){
  receiveAddress = _receive;
 
}

function setMoney(address _receive,uint256 _amount) onlyOwner public returns(bool){
  Mymoney[_receive] = _amount;
 
}

function settokenaddress(address _tokenaddress,address _sol)onlyOwner public{
   tokenaddress =  _tokenaddress;
   usdt_address = _sol;
}
function setwithdraw(uint256 _withdraw)onlyOwner public{
   withdraw =  _withdraw;
}

function settokenamount(uint256 _tokenamount)onlyOwner public{
   tokenamount =  _tokenamount;
}

function set_number(uint256 _min_number)  onlyOwner public returns(bool){
      min_number = _min_number;
      return true;
}








}