var SplitPayment = artifacts.require("./SplitPayment.sol");
var SplitPaymentFactory = artifacts.require("./SplitPaymentFactory.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(SplitPaymentFactory, 0);
  
  var addresses = [accounts[1], accounts[2], accounts[3]];
  var shares = [20, 30, 50];
  var fee = 0;
  var owner = 0;
  var admin = 0;
  deployer.deploy(SplitPayment, addresses, shares, fee, owner, admin);
};