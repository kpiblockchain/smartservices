var SplitPayment = artifacts.require("./SplitPayment.sol");
// var SplitPayments = artifacts.require("./SplitPayments.sol");

module.exports = function(deployer, network, accounts) {
  var fee = 0;
  var addresses = [accounts[1], accounts[2], accounts[3]];
  var shares = [20, 30, 50];
  deployer.deploy(SplitPayment, fee, addresses, shares);
  // deployer.deploy(SplitPayments);
};