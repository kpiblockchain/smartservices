pragma solidity ^0.4.0;
import "contracts/SplitPayment.sol";

contract SplitPaymentFactory {
    address public provider; // service provider
    uint    public fee; // fee for all created contracts by this factory instance
    
    modifier ownerOnly() {
        require(msg.sender == provider);
        _;
    }

    function SplitPaymentFactory(uint _fee) public {
        provider = msg.sender;
        fee = _fee;
    }

    function create(address[] _accounts, uint[] _shares) public returns (address contractAddress) {
        contractAddress = new SplitPayment(_accounts, _shares, fee, provider, msg.sender);
        // TODO ContractCreatedEvent(contractAddress);
    }

    function destroy() public ownerOnly {
        selfdestruct(provider);
    }
}