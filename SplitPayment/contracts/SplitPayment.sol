pragma solidity ^0.4.0;

/// Kontrakt per zasób
contract SplitPayment {
    
    struct Shareholder {
        address account; // adres konta
        uint share; // waga
    }

    uint fee; // opłata, w procentach
    address provider; // adres zarządzający dostępem do zasobu
    uint sharesSum; // suma wag zasobu
    Shareholder[] shareholders; // adresy mające prawa do zasobu
    
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
    
    function addShareholder(address account, uint share) public providerOnly() {
        shareholders.push(Shareholder(account, share));
        sharesSum += share;
    }
    
    function addShareholders(address[] accounts, uint[] shares) public providerOnly() areEqual(accounts.length, shares.length) {
        uint count = accounts.length;
        for (uint i = 0; i < count; i++) {
            shareholders.push(Shareholder(accounts[i], shares[i]));
            sharesSum += shares[i];
        }
    }
    
    function() payable public {
        uint length = shareholders.length;
        uint sharesSumAfterFee = sharesSum * (100 + fee) / 100;
        for (uint i = 0; i < length; i++) {
            var shareholder = shareholders[i];
            shareholder.account.transfer(msg.value * shareholder.share / sharesSumAfterFee);
        }
    }

    function getFee() public providerOnly() {
        provider.transfer(this.balance);
    }
    
    function destroyContract() public providerOnly {
        selfdestruct(provider);
    }
}