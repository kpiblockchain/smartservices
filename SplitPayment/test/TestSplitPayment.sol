pragma solidity ^0.4.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SplitPayment.sol";

contract TestSplitPayment {
    SplitPayment splitPayment = SplitPayment(DeployedAddresses.SplitPayment());

    function testThatProviderIsSet() public {
        Assert.equal(splitPayment._provider(), tx.origin, "I should be the provider");
    }

    function testThatFeeIsSet() public {
        Assert.equal(splitPayment._fee(), 0, "Default fee should be 0");
    }

    function testThatSharesSumIsSet() public {
        Assert.equal(splitPayment._sharesSum(), 100, "Default sharesSum should be 100");
    }
}