pragma solidity ^0.4.0;
import "zeppelin-solidity/contracts/math/SafeMath.sol";

/// TODO token za płatność - tak, ograniczony, warunkowy
contract SplitPayment { // TODO name change to TransferableShareSplitPayment ?
    using SafeMath for uint256;

    address   public provider; // adres zarządzający dostępem do zasobu
    address   public factory; // adres fabryki
    address   public admin; // adres administratora (płacącego za kontrakt)
    uint256   public fee; // opłata za wpłaty, w procentach, dla {provider}

    mapping(address => address) private next;
    mapping(address => address) private previous;
    address                     private last;

    mapping(address => uint256) public shares; // account => share
    uint256                     public sharesSum; // suma udziałów

    event ShareholderAddedEvent(
        address account,
        uint256 share
    );

    event ShareTransferEvent(
        address from,
        address to,
        uint256 transferedShares
    );

    event PaymentEvent(
        uint256 payedAmount
    );

    event SharesMultipliedEvent(
        uint256 multiplier
    );
    
    modifier providerOnly() {
        require(msg.sender == provider); _;
    }
    
    modifier adminOnly() {
        require(msg.sender == admin); _;
    }
    
    modifier providerOrAdmin() {
        require(msg.sender == provider || msg.sender == admin); _;
    }
    
    modifier providerOrFactory() {
        require(msg.sender == provider || msg.sender == factory); _;
    }
    
    modifier validateFee(uint256 _fee) {
        require(_fee < 100); _;
    }

    function SplitPayment(address[] _accounts, uint256[] _shares, uint256 _fee, address _provider, address _admin) public validateFee(_fee) {
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
    
    function initShareholders(address[] _accounts, uint256[] _shares) internal providerOrFactory() {
        require(_accounts.length == _shares.length);
        require(_accounts.length > 0);
        
        uint256 count = _accounts.length;
        for (uint256 i = 0; i < count; i++) {
            initShareholder(_accounts[i], _shares[i]);
        }
    }

    function initShareholder(address _account, uint256 _share) internal {
        require(_share > 0);
        require(_account != address(0));
        require(shares[_account] == 0);

        if (last == address(0)) {
            last = _account;
        } else {
            next[last] = _account;
            previous[_account] = last;
            last = _account;
        }
        shares[_account] = _share;
        sharesSum = sharesSum.add(_share);
        ShareholderAddedEvent(_account, _share);
    }

    function transferShares(address _recipient, uint256 _sharesToTransfer) public {
        require(_recipient != address(0));
        require(msg.sender != _recipient);
        require(_sharesToTransfer > 0);
        require(shares[msg.sender] >= _sharesToTransfer);

        if (shares[_recipient] == 0) { // if _recipient account should be added:
            next[last] = _recipient;
            previous[_recipient] = last;
            last = _recipient;
        }
        shares[_recipient] = shares[_recipient].add(_sharesToTransfer);
        shares[msg.sender] = shares[msg.sender].sub(_sharesToTransfer);
        if (shares[msg.sender] == 0) { // if msg.sender account should be removed:
            var senderNext = next[msg.sender];
            var senderPrevious = previous[msg.sender];

            next[senderPrevious] = senderNext;
            previous[senderNext] = senderPrevious;
            if (msg.sender == last) {
                last = senderPrevious;
            }
            // TODO clear loose 'references'?
        }
        ShareTransferEvent(msg.sender, _recipient, _sharesToTransfer);
    }
    
    function() payable public {
        uint256 sharesSumAfterFee = _deductFeeFromShareSum();
        var currentAccount = last;
        while (currentAccount != address(0)) {
            currentAccount.transfer(msg.value.mul(shares[currentAccount]).div(sharesSumAfterFee));
            currentAccount = previous[currentAccount];
        }
        PaymentEvent(msg.value);
    }

    function _deductFeeFromShareSum() view internal returns (uint256) {
        if (fee == 0) {
            // 0% fee
            return sharesSum;
        }
        // >0% fee
        return sharesSum.mul(fee.add(100)).div(100); 
    }

    function multiplyShares(uint256 _multiplier) public adminOnly() { // TODO consensus or vote?
        require(_multiplier > 0);

        // TODO safe multiplication
        var currentAccount = last;
        while (currentAccount != address(0)) {
            shares[currentAccount] = shares[currentAccount].mul(_multiplier);
            currentAccount = previous[currentAccount];
        }
        sharesSum = sharesSum.mul(_multiplier);
        SharesMultipliedEvent(_multiplier);
    }

    function myShares() public view returns(uint256 _shares, uint256 _sharePercantage) {
        _shares = shares[msg.sender];
        _sharePercantage = shares[msg.sender].mul(100).div(sharesSum);
    }

    function collectFee() public providerOnly() returns(uint256 _collectedAmount) {
        _collectedAmount = this.balance;
        provider.transfer(this.balance);
    }
    
    function destroy() public providerOrAdmin() {
        // TODO clear all storage?
        selfdestruct(provider);
    }
}