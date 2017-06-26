var PayoutHub = artifacts.require("./PayoutHub.sol");

contract('PayoutHub', function(accounts) {
  it("should configure hub", function() {
    var hub;

    // Get initial balances of first and second account.
    var account_one = accounts[0];
    var account_two = accounts[1];
    var account_three = accounts[2];

    return PayoutHub.deployed().then(function(instance) {
      hub = instance;
      });
  });
});
