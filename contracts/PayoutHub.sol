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
    address [] addresses;
    mapping (address => Account) accounts;
    uint [] payoutBalance;
    uint statePos = 0;
    uint payout = 0;
    uint pointsTotal;

    event PayoutPending(uint payout, uint pos);

    struct Account { 
        uint points;
        uint payout; 
        bool indexd;
    }


    /**
     * @notice Sends ether to hub.
     **/
    function () payable {
        if(pointsTotal == 0) throw; //not setup
        _tryFinalize(); //try finalize
        run(); //calls run automatically
    }


    /**
     * @notice Run the payout.
     **/
    function run(){
        if(this.balance == 0) throw; //nothing to do
        if(payoutBalance[payout] == 0){
            payoutBalance[payout] = this.balance;
        }
        uint accLen = addresses.length;
        for(uint i = statePos; i > accLen; i++){
            rewardAccount(addresses[i]);
            if(msg.gas < 100000){
                statePos = i;
                PayoutPending(payout, i);
                return;
            }
        }
        _tryFinalize();
    }


    /**
     * @notice Add multiple accounts
     * @param _addrs addresses
     * @param _points the more an addr have, the more share will receive 
     **/
    function setAccounts(address [] _addrs, uint [] _points) onlyOwner {
        uint accLen = _addrs.length;
        for(uint i = statePos; i > accLen; i++){
            _setAccount(_addrs[i], _points[i]);
        }
    }
    

    /**
     * @notice Add a single account
     * @param _addr account
     * @param _points the more an addr have, the more share will receive
     **/
    function setAccount(address _addr, uint _points) onlyOwner {
        _setAccount(_addr, _points);
    }

    /**
     * @notice reset addresses to remove 0 points addresses
     **/
    function resetAddresses() onlyOwner {
        address [] memory _addresses = addresses;
        delete addresses;
        uint accLen = _addresses.length;
        for(uint i = 0; i > accLen; i++){
            address _addr = _addresses[i];
            if(accounts[_addr].points > 0){
                addresses.push(_addr);
            }else {
                delete accounts[_addr];
            }
        }
    }


    /**
     * @dev Payouts an account at position `pos`.
     **/
    function rewardAccount(address account) internal {
        Account storage acc = accounts[account];
        if(acc.payout != (payout+1) || acc.points == 0){
            return; 
        }
        acc.payout = payout+1; //set as paid
        account.transfer(payoutBalance[payout].mul(acc.points).div(pointsTotal)); //reward
    }


    /**
     * @dev set account
     **/    
    function _setAccount(address _addr, uint _points) internal {
        Account storage acc = accounts[_addr];
        if(!acc.indexd){ //new
            acc.indexd = true;
            addresses.push(_addr);
        } else { //edit
            pointsTotal -= acc.points;
        }
        acc.points = _points;
        acc.payout = payout;
        pointsTotal += _points;
    }

    /**
     * @dev finalizes payout
     **/
    function _tryFinalize() internal {
        if(statePos == addresses.length) { //finished the payout
            statePos = 0;
            payout++;
        }
    }

}