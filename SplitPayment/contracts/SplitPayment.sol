pragma solidity ^0.4.0;

/// Kontrakt per zasób
/// Token za płatność
contract SplitPayment {
    
    struct Shareholder {
        address account; // adres konta
        uint share; // waga
    }

    uint public fee; // opłata, w procentach
    address public provider; // adres zarządzający dostępem do zasobu
    uint public sharesSum; // suma wag zasobu
    Shareholder[] public shareholders; // adresy mające prawa do zasobu

    event ShareholderAddedEvent(
        address shareholderAddress,
        uint shareholderShare
    );

    event PaymentEvent(
        uint payedAmount
    );
    
    modifier validateFee(uint feePercent) {
        require(feePercent < 100);
        _;
    }
    
    modifier providerOnly() {
        require(msg.sender == provider);
        _;
    }
    
    modifier areEqual(uint first, uint second) {
        require(first == second);
        _;
    }

    function SplitPayment(uint feePercent, address[] accounts, uint[] shares) public validateFee(feePercent) {
        provider = msg.sender;
        fee = feePercent;
        addShareholders(accounts, shares);
    }
    
    function addShareholders(address[] accounts, uint[] shares) public providerOnly() areEqual(accounts.length, shares.length) {
        uint count = accounts.length;
        for (uint i = 0; i < count; i++) {
            addShareholder(accounts[i], shares[i]);
        }
    }
    
    function addShareholder(address account, uint share) public providerOnly() {
        shareholders.push(Shareholder(account, share));
        sharesSum += share;
        ShareholderAddedEvent(account, share);
    }
    
    function() payable public {
        uint length = shareholders.length;
        uint sharesSumAfterFee = deductFeeFromShareSum();
        for (uint i = 0; i < length; i++) {
            var shareholder = shareholders[i];
            shareholder.account.transfer(msg.value * shareholder.share / sharesSumAfterFee);
        }
        PaymentEvent(msg.value);
    }

    function deductFeeFromShareSum() view internal returns (uint) {
        if (fee == 0) {
            // 0% fee
            return sharesSum;
        }
        // >0% fee
        return sharesSum * (100 + fee) / 100; 
    }

    function collectFee() public providerOnly() returns(uint collectedAmount) {
        collectedAmount = this.balance;
        provider.transfer(this.balance);
    }
    
    function destroyContract() public providerOnly {
        selfdestruct(provider);
    }
}