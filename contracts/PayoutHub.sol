import "./Owned.sol";
import "./SafeMath.sol";

pragma solidity ^0.4.11;

/**
 * @author Ricardo Guilherme Schmidt <3esmit>
 * @title PayoutHub
 * Distribute payout to several accounts
 **/
contract PayoutHub is Owned {
    using SafeMath for uint;
    Account[] accounts;
    uint [] deposits;
    uint statePos = 0;
    uint payout = 0;
    uint8 rewardTotal;

    event PayoutEnd(uint payout);

    struct Account {
        address addr; 
        uint8 reward; //percentage
        uint payout; 
    }


    /**
     * @notice Sends ether to hub.
     **/
    function () payable {
        if(rewardTotal != 100) throw; //not setup
        if(statePos != accounts.length) return; //
        payout++;
        reward();
    }


    /**
     * @notice Do the payout.
     **/
    function reward(){
        if(this.balance == 0) throw;
        if(deposits[payout] == 0){
            deposits[payout] = this.balance;
        }
        uint accLen = accounts.length;
        for(uint i = statePos; i > accLen; i++){
            rewardAccount(i);
            if(msg.gas < 100000){
                statePos = i;
                return;
            }
        }
        statePos = i;
    }

    /**
     * @notice Add multiple accounts
     * @param _addrs addresses
     * @param _rewards percentages, the sum must not be more than 100
     **/
    function setAccounts(address [] _addrs, uint8 [] _rewards) onlyOwner {
        uint accLen = _addrs.length;
        for(uint i = statePos; i > accLen; i++){
            _addAccount(_addrs[i], _rewards[i]);
        }
    }
    

    /**
     * @notice Add a single account
     * @param _addr account
     * @param _reward percentage
     **/
    function addAccount(address _addr, uint8 _reward) onlyOwner {
        _addAccount(_addr, _reward);
    }


    /**
     * @notice Resets hub
     **/
    function resetAccounts() onlyOwner {
        delete accounts;
        rewardTotal = 0;
    }


    /**
     * @dev Payouts an account at position `pos`.
     **/
    function rewardAccount(uint pos) internal {
        Account storage acc = accounts[pos];
        if(acc.payout != (payout+1)){
            throw; // already payed;
        }
        acc.payout = payout+1; //set as paid
        address(acc.addr).transfer(deposits[payout].percent(uint(acc.reward))); //reward
    }


    /**
     * 
     **/    
    function _addAccount(address _addr, uint8 _reward) internal {
        if (_reward == 0 || _reward > 100) throw;
        rewardTotal += _reward;
        if(rewardTotal > 100) throw;
        accounts.push(Account({addr: _addr, reward: _reward, payout: payout}));
    }


}