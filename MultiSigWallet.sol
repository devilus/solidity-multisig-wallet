pragma solidity ^0.8.0;

import "./Wallet.sol";

contract MultiSigWallet is Wallet {
    
     constructor(address[] memory _additionalOwners, uint8 _numberOfApprovals) {
        require (_numberOfApprovals <= _additionalOwners.length, "Approvals number more than the wallet owners.");

        mainOwner = msg.sender;
        numberOfApprovals = _numberOfApprovals;
        additionalOwners = _additionalOwners;
    }
    
    function deposit() public payable returns (uint256) {
        require (msg.value > 0, "Deposit must be greater than zero.");
        
        uint256 balanceBeforeDeposit = walletBalance;
        walletBalance += msg.value;
        
        assert(walletBalance == balanceBeforeDeposit + msg.value);
        emit NewDeposit(msg.value);
        
        return walletBalance;
    }
    
    function withdraw(address _to, uint256 _amount) public onlyOwners returns (Transaction memory) {
        require (_amount <= walletBalance, "Insufficent wallet balance.");
        
        // Create new transaction
        address[] memory approvedFrom;
        Transaction memory newTransaction = Transaction(msg.sender, _to, _amount, 0, approvedFrom);
        transactions.push(newTransaction);
        
        // Call approve method immediately if number of approvals was set to 0
        if (numberOfApprovals == 0) {
            approve(transactions.length - 1);
        }
        
        emit NewWithdraw(_amount);
        
        return newTransaction;
    }
    
    function approve(uint256 _txId) public onlyOwners returns (Transaction memory) {
        require(transactions[_txId].approvals < numberOfApprovals, "Transaction has already been approved and sent.");
        require(msg.sender != transactions[_txId].from && numberOfApprovals > 0, "Transaction need to be approved by another owner."); // prevent approve by myself
        
        // Prevent approvals duplication
        require(!_isApprovedEarlier(_txId, msg.sender), "Transaction has already been approved by this owner.");
        
        transactions[_txId].approvals++; // increase transaction approvals
        transactions[_txId].approvedFrom.push(msg.sender); // add transaction approver
        
        // Transfer eth if approvals number was reached the desired
        if (transactions[_txId].approvals >= numberOfApprovals) {
            _transfer(transactions[_txId].to, transactions[_txId].amount);
        }
        
        return transactions[_txId];
    }
    
    // Getters
    function getWalletBalance() public view returns (uint256) {
        return walletBalance;
    }
    
    function getTransactionsList() public view returns (Transaction[] memory) {
        return transactions;
    }
    
}
