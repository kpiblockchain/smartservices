pragma solidity ^0.4.0;
/// Kontrakt per zasób
contract SplitPayment {
    
    struct Shareholder {
        address account; // adres konta
        uint256 share; // waga
    }
    
    address provider; // adres zarządzający dostępem do zasobu
    Shareholder[] shareholders; // adresy mające prawa do zasobu
    uint256 sharesSum; // suma wag zasobu
    //bool valid; // zasób może zostać usunięty/wyłączony
    
    function SplitPayment() public {
        provider = msg.sender;
    }
    
    modifier providerOnly() {
        require(msg.sender == provider);
        _;
    }
    
    function addOrUpdateShareholder(address account, uint256 share) public providerOnly() {
        shareholders.push(Shareholder(account, share));
        sharesSum += share;
    }
    
    function() payable public {
        uint256 length = shareholders.length;
        for (uint i = 0; i < length; i++) {
            var shareholder = shareholders[i];
            shareholder.account.transfer(msg.value * (shareholder.share * 1000000 / sharesSum) / 1000000);
        }
    }
    
    /*function remove(uint256 resourceId) public providerOnly(resourceId) {
        // todo invalidate resource
    }*/
    
    function destroyContract() public providerOnly {
        selfdestruct(provider);
    }
}