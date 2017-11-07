var SplitPayment = artifacts.require("./SplitPayment.sol");
var SplitPayments = artifacts.require("./SplitPayments.sol");

module.exports = function(deployer) {
  deployer.deploy(SplitPayment);
  deployer.deploy(SplitPayments);
};