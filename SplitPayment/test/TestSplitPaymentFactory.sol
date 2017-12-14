pragma solidity ^0.4.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SplitPaymentFactory.sol";

contract TestSplitPaymentFactory {
    SplitPaymentFactory factory = SplitPaymentFactory(DeployedAddresses.SplitPaymentFactory());

    function testThatFactoryOwnerIsSet() public {
        Assert.equal(factory.provider(), tx.origin, "I should be the owner");
    }

    function testThatFactoryFeeIsSet() public {
        Assert.equal(factory.fee(), 0, "Default fee shoud be 0");
    }
}