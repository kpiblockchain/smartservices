pragma solidity ^0.4.0;
/// Kontrakt per zasób
contract SplitPayment {
    
    struct Shareholder {
        address account; // adres konta
        uint256 share; // waga
    }
    
    struct Resource {
        address provider; // adres zarządzający dostępem do zasobu
        Shareholder[] shareholders; // adresy mające prawa do zasobu
        uint256 sharesSum; // suma wag zasobu
        //bool valid; // zasób może zostać usunięty/wyłączony
    }
    
    Resource resource;
    
    function SplitPayment() public {
        resource.provider = msg.sender;
    }
    
    modifier providerOnly() {
        require(msg.sender == resource.provider);
        _;
    }
    
    function addOrUpdateShareholder(address account, uint256 share) public providerOnly() {
        resource.shareholders.push(Shareholder(account, share));
        resource.sharesSum += share;
    }
    
    function() payable public {
        for (uint i = 0; i < resource.shareholders.length; i++) {
            var shareholder = resource.shareholders[i];
            shareholder.account.transfer(msg.value * (shareholder.share * 1000000 / resource.sharesSum) / 1000000);
        }
    }
    
    /*function remove(uint256 resourceId) public providerOnly(resourceId) {
        // todo invalidate resource
    }*/
    
    /*function destroyContract() public ownerOnly {
        selfdestruct(owner);
    }*/
}