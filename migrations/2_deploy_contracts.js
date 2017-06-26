var SafeMath = artifacts.require("./SafeMath.sol");
var PayoutHub = artifacts.require("./PayoutHub.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, PayoutHub);
  deployer.deploy(PayoutHub);
};
