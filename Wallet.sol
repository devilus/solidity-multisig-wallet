pragma solidity ^0.8.0;

contract Wallet {
    
    uint256 internal walletBalance;
    uint8 internal numberOfApprovals;
    address internal mainOwner;
    address[] internal additionalOwners;
    
    // Transaction object
    struct Transaction {
        address from;
        address to;
        uint256 amount;
        uint8 approvals;
        address[] approvedFrom;
    }
    
    Transaction[] transactions; // array of transactions
    
    event NewDeposit(uint256 _amount);
    event NewWithdraw(uint256 _amount);
    
    modifier onlyOwners {
        require (_isOwner(msg.sender), "You're not the wallet owner.");
        _;
    }
    
    function _isOwner(address _sender) private view returns (bool) {
         if (_sender == mainOwner) {
             return true;
         }
        
        // Check additional owners
        for (uint8 i = 0; i < additionalOwners.length; i++) {
           if (additionalOwners[i] == _sender) {
            return true;
           }
        }
        
        return false;
    }
    
    function _isApprovedEarlier(uint256 _txId, address _sender) internal view returns (bool) {
        for (uint8 i = 0; i < transactions[_txId].approvedFrom.length; i++) {
            if (_sender == transactions[_txId].approvedFrom[i]) {
                return true;
            }
        }
        
        return false;
    }
    
    function _transfer(address _to, uint256 _amount) internal {
        require (_amount <= walletBalance, "Insufficent wallet balance.");
         
        uint256 balanceBeforeWithdraw = walletBalance;
        walletBalance -= _amount;
        
        payable(_to).transfer(_amount);
         
        assert(walletBalance == balanceBeforeWithdraw - _amount);
    }
}
