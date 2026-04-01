pragma solidity ^0.8.0;

contract Vault {
    mapping(address=>uint256) public balances;
    mapping(address=>uint256) public lockTime;
    address public owner ;

    event Deposited(address indexed user , uint256 amount );
    event Withdrawn(address indexed user,   uint256 amount);

    constructor(){
        owner=msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner , "Not owner");
        _;
    }
    
    function deposit() external payable {
        require(msg.value > 0 ,"No ether sent");
        balances[msg.sender] += msg.value ;
        lockTime[msg.sender] = block.timestamp + 7 days ;
        emit Deposited(msg.sender,msg.value);
    }

    function withdraw(uint256 amount)external{
        require(balances[msg.sender] >= amount,"Insufficient balance");
        require(block.timestamp >= lockTime[msg.sender],"Locked");

        balances[msg.sender] -= amount ;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender,amount);
    }

    function emergencyWithdraw() external onlyOwner{
        payable(owner).transfer(address(this).balance);
    }
}