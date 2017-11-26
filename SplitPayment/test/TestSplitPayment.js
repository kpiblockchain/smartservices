var SplitPayment = artifacts.require("SplitPayment");

contract('SplitPayment', function(accounts) {
  it("tests other stuff", function() {
    var sp;
    var amount = web3.toBigNumber(web3.toWei(10));

    var account1 = accounts[1];
    var account2 = accounts[2];
    var account3 = accounts[3];

    var account1Share = 20;
    var account2Share = 30;
    var account3Share = 50;
    var shareSum = 100;
    var fee = 0;

    var account1Ballance = GetBalance(account1);
    var account2Ballance = GetBalance(account2);
    var account3Ballance = GetBalance(account3);

    return SplitPayment.deployed().then(function(instance) {
        sp = instance;
        return sp.send(amount);
    }).then(function() {
        AssertBalance(account1, account1Ballance, account1Share, shareSum, amount);
        AssertBalance(account2, account2Ballance, account2Share, shareSum, amount);
        AssertBalance(account3, account3Ballance, account3Share, shareSum, amount);
    });
  });
});

function GetBalance(account) {
    return web3.eth.getBalance(account);
}

function AssertBalance(account, previousBalance, share, shareSum, amount) {
    assert.equal(GetBalance(account).toString(), previousBalance.add(amount.mul(share / shareSum)).toString(), "Account '" + account + "' has incorrect balance");
}