pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/PayoutHub.sol";

contract TestPayoutHub {

  function testInitialUsingDeployedContract() {
    PayoutHub meta = PayoutHub(DeployedAddresses.PayoutHub());
  }

  function testInitialWithNewPayoutHub() {
    PayoutHub meta = new PayoutHub();
  }

}
