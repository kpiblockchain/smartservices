pragma solidity ^0.4.0;
import "contracts/SplitPayment.sol";

contract SplitPaymentFactory {
    address public _provider; // service provider
    uint    public _fee; // fee for all created contracts by this factory instance
    
    modifier ownerOnly() {
        require(msg.sender == _provider);
        _;
    }

    function SplitPaymentFactory(uint fee) public {
        _provider = msg.sender;
        _fee = fee;
    }

    function create(address[] accounts, uint[] shares) public returns (address contractAddress) {
        contractAddress = new SplitPayment(accounts, shares, _fee, _provider, msg.sender);
    }

    function destroy() public ownerOnly {
        selfdestruct(_provider);
    }
}