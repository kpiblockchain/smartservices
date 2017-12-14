pragma solidity ^0.4.0;

/// token za płatność - tak
/// token platformy - jeszcze nie?
/// platforma do zarządzania fanklubami przez artystów
/// opłata aktywacyjna
/// darmowe usługi dla właścicieli tokenów platformy - ?
contract SplitPayment {
    address   public provider; // adres zarządzający dostępem do zasobu
    address   public factory; // adres fabryki
    address   public admin; // adres administratora (płacącego za kontrakt)
    uint      public fee; // opłata za wpłaty, w procentach, dla {provider}

    mapping(address => address) private next;
    mapping(address => address) private previous;
    address private first;
    address private last;
    mapping(address => uint) public shares; // account => share
    uint                     public sharesSum; // suma udziałów

    event ShareholderAddedEvent(
        address account,
        uint share
    );

    event ShareTransferEvent(
        address from,
        address to,
        uint transferedShares
    );

    event PaymentEvent(
        uint payedAmount
    );
    
    modifier providerOnly() {
        require(msg.sender == provider); _;
    }
    
    modifier providerOrAdmin() {
        require(msg.sender == provider || msg.sender == admin); _;
    }
    
    modifier providerOrFactory() {
        require(msg.sender == provider || msg.sender == factory); _;
    }
    
    modifier validateFee(uint _fee) {
        require(_fee < 100); _;
    }

    function SplitPayment(address[] _accounts, uint[] _shares, uint _fee, address _provider, address _admin) public validateFee(_fee) {
        _setProvider(_provider);
        _setAdmin(_admin);
        factory = msg.sender;
        fee = _fee;
        initShareholders(_accounts, _shares);
    }

    function _setProvider(address _provider) internal {
        if (_provider == 0) {
            provider = msg.sender;
        } else {
            provider = _provider;
        }
    }

    function _setAdmin(address _admin) internal {
        if (_admin == 0) {
            admin = msg.sender;
        } else {
            admin = _admin;
        }
    }
    
    function initShareholders(address[] _accounts, uint[] _shares) internal providerOrFactory() {
        require(_accounts.length == _shares.length);
        require(_accounts.length > 0);
        
        uint count = _accounts.length;
        for (uint i = 0; i < count; i++) {
            initShareholder(_accounts[i], _shares[i]);
        }
    }

    function initShareholder(address _account, uint _share) internal {
        require(_share > 0);
        require(_account != 0x0);

        if (first == 0x0) {
            first = _account;
            last = _account;
        } else {
            next[last] = _account;
            previous[_account] = last;
            last = _account;
        }
        shares[_account] = _share;
        sharesSum += _share;
        ShareholderAddedEvent(_account, _share);
    }

    function transferShares(address _recipient, uint _sharesToTransfer) public {
        require(_recipient != 0x0);
        require(msg.sender != _recipient);
        require(_sharesToTransfer > 0);
        require(shares[msg.sender] >= _sharesToTransfer);

        if (shares[_recipient] == 0) { // create account:
            next[last] = _recipient;
            previous[_recipient] = last;
            last = _recipient;
        }
        shares[_recipient] += _sharesToTransfer;
        shares[msg.sender] -= _sharesToTransfer;
        if (shares[msg.sender] == 0) {
            next[previous[msg.sender]] = next[msg.sender];
            previous[next[msg.sender]] = previous[msg.sender];
            if (msg.sender == last) {
                last = previous[msg.sender];
            }
            // clear loose 'references'?
        }
        ShareTransferEvent(msg.sender, _recipient, _sharesToTransfer);
    }

    // TODO function getAllShareholders public
    
    function() payable public {
        uint sharesSumAfterFee = _deductFeeFromShareSum();
        var currentAccount = first;
        while (currentAccount != 0x0) {
            currentAccount.transfer(msg.value * shares[currentAccount] / sharesSumAfterFee);
            currentAccount = next[currentAccount];
        }
        PaymentEvent(msg.value);
    }

    function _deductFeeFromShareSum() view internal returns (uint) {
        if (fee == 0) {
            // 0% fee
            return sharesSum;
        }
        // >0% fee
        return sharesSum * (100 + fee) / 100; 
    }

    function collectFee() public providerOnly() returns(uint _collectedAmount) {
        _collectedAmount = this.balance;
        provider.transfer(this.balance);
    }
    
    function destroy() public providerOrAdmin() {
        // TODO clear all storage?
        selfdestruct(provider);
    }
}