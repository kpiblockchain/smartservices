pragma solidity ^0.4.0;

/// Kontrakt per zasób
/// Token za płatność
/// Token platformy
/// Platforma do zarządzania fanklubami przez artystów
/// Aktywacyjna opłata per contract + opłata
/// obsłużenie mniejszych lub większych
/// darmowe usługi dla właścicieli tokenów platformy

/// opisać cały proces aktywacji - znaleźć problemy
contract SplitPayment {
    
    struct Shareholder {
        address account; // adres konta
        uint share; // waga
    }

    address public _provider; // adres zarządzający dostępem do zasobu
    address public _factory; // adres fabryki
    address public _admin; // adres administratora (płacącego za kontrakt)
    uint    public _fee; // opłata za wpłaty, w procentach
    uint    public _sharesSum; // suma wag zasobu
    Shareholder[] public _shareholders; // adresy mające prawa do zasobu

    event ShareholderAddedEvent(
        address shareholderAddress,
        uint shareholderShare
    );

    event PaymentEvent(
        uint payedAmount
    );
    
    modifier providerOnly() {
        require(msg.sender == _provider); _;
    }
    
    modifier adminOrProvider() {
        require(msg.sender == _admin || msg.sender == _provider); _;
    }
    
    modifier factoryOrProvider() {
        require(msg.sender == _factory || msg.sender == _provider); _;
    }
    
    modifier validateFee(uint fee) {
        require(fee < 100); _;
    }
    
    modifier areEqual(uint first, uint second) {
        require(first == second); _;
    }

    function SplitPayment(address[] accounts, uint[] shares, uint fee, address provider, address admin) public validateFee(fee) {
        _setProvider(provider);
        _setAdmin(admin);
        _factory = msg.sender;
        _fee = fee;
        addShareholders(accounts, shares);
    }
    
    function addShareholders(address[] accounts, uint[] shares) public factoryOrProvider() areEqual(accounts.length, shares.length) {
        uint count = accounts.length;
        for (uint i = 0; i < count; i++) {
            addShareholder(accounts[i], shares[i]);
        }
    }
    
    function addShareholder(address account, uint share) public factoryOrProvider() {
        _shareholders.push(Shareholder(account, share));
        _sharesSum += share;
        ShareholderAddedEvent(account, share);
    }
    
    function() payable public {
        uint length = _shareholders.length;
        uint sharesSumAfterFee = _deductFeeFromShareSum();
        for (uint i = 0; i < length; i++) {
            var shareholder = _shareholders[i];
            shareholder.account.transfer(msg.value * shareholder.share / sharesSumAfterFee);
        }
        PaymentEvent(msg.value);
    }

    function _deductFeeFromShareSum() view internal returns (uint) {
        if (_fee == 0) {
            // 0% _fee
            return _sharesSum;
        }
        // >0% _fee
        return _sharesSum * (100 + _fee) / 100; 
    }

    function _setProvider(address provider) internal {
        if (provider == 0) {
            _provider = msg.sender;
        } else {
            _provider = provider;
        }
    }

    function _setAdmin(address admin) internal {
        if (admin == 0) {
            _admin = msg.sender;
        } else {
            _admin = admin;
        }
    }

    function collectFee() public providerOnly() returns(uint collectedAmount) {
        collectedAmount = this.balance;
        _provider.transfer(this.balance);
    }
    
    function destroy() public adminOrProvider() {
        selfdestruct(_provider);
    }
}