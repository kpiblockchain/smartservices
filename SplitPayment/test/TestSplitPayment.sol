pragma solidity ^0.4.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SplitPayment.sol";

contract TestSplitPayment {
    SplitPayment splitPayment = SplitPayment(DeployedAddresses.SplitPayment());

    function test() {
        // TODO
        Assert.fail("TODO");
    }
}