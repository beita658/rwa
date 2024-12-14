pragma solidity ^0.8.0;
 interface ERC20 {


function balanceOf(address _owner) external view returns (uint balance);
function transfer(address _to, uint _value) external returns (bool success);
function transferFrom(address _from, address _to, uint _value) external returns (bool success);
function approve(address _spender, uint _value) external returns (bool success);
function allowance(address _owner, address _spender) external view returns (uint remaining);


}
contract LoanProtocol {
    struct Loan {
       
        address lender;
        uint256 amount; 
        uint256 interestRate; 
        uint256 term; 
        bool active; 
    }
    address public token=0x5efA26581e1F1eACA8bBF957821174dcCd88ebF9;
 address public contracts=0x330751319acF5C24c088B5bF29850f56dd933C50;
    mapping(address => uint256) public collateral; 
    mapping(uint256 => Loan) public loans; 
    uint256 public numLoans = 0; 
    mapping(address => uint256[])public userloadids;
 
   
    function depositCollateral(uint256 amount) public  {
        ERC20(token).transferFrom(msg.sender,address(this),amount);
        collateral[msg.sender] += amount;
    }
 

    function requestLoan( uint256 amount, uint256 interestRate, uint256 term) public {
        loans[numLoans] = Loan({
            lender: msg.sender,
            amount: amount,
            interestRate: interestRate,
            term: term,
            active: true
        });
        userloadids[msg.sender].push(numLoans);
        numLoans++;
      ERC20(token).transfer(msg.sender,amount);
    
        require(collateral[msg.sender] >= amount, "Not enough collateral");
        collateral[msg.sender] -= amount;
    }
 
   
    function repayLoan(uint256 loanId) public  {
        Loan storage loan = loans[loanId];
        require(loan.lender == msg.sender, "Not the borrower");
        require(loan.active, "Loan is not active");
     
        uint256 all_amount = loan.amount + loan.amount*loan.interestRate/100;
         ERC20(token).transferFrom(msg.sender,address(this),all_amount);
         ERC20(token).transfer(contracts,loan.amount*loan.interestRate/100);
         loan.active = false;
          collateral[msg.sender] += loan.amount;
    }
 
   
    function releaseCollateral() public {
        uint256 amount = collateral[msg.sender];
        collateral[msg.sender] = 0;
 ERC20(token).transfer(msg.sender,amount);
    }
}