pragma solidity ^0.4.0;
/// Kontrakt 'globalny', zawierający wszystkie zasoby
contract SplitPayments {
    
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

    address owner;
    mapping(uint256 => Resource) resources; // resourceId => Resource
    uint256 resourceCounter; // służy do uzyskania unikalnego* ID
    
    function SplitPayments() public {
        owner = msg.sender;
    }
    
    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }
    
    modifier providerOnly(uint256 resourceId) {
        require(msg.sender == resources[resourceId].provider);
        _;
    }
    
    function addResource() public returns (uint256 resourceId) {
        resourceId = resourceCounter++;
        resources[resourceId].provider = msg.sender;
    }
    
    function addOrUpdateShareholder(uint256 resourceId, address account, uint256 share) public providerOnly(resourceId) {
        // todo: update part
        var resource = resources[resourceId];
        resource.shareholders.push(Shareholder(account, share));
        resource.sharesSum += share;
    }
    
    /*function addOrUpdateShareholder(uint256 resourceId, address account, uint256 share) public {
        addOrUpdateShareholder(resourceId, Shareholder(account, share));
    }
    
    function addOrUpdateShareholder(uint256 resourceId, Shareholder shareholder) public providerOnly(resourceId) {
        // todo: update part
        var resource = resources[resourceId];
        resource.shareholders.push(shareholder);
        resource.sharesSum += shareholder.share;
    }*/
    
    function pay(uint256 resourceId) payable public {
        var resource = resources[resourceId];
        for (uint i = 0; i < resource.shareholders.length; i++) {
            var shareholder = resource.shareholders[i];
            shareholder.account.transfer(msg.value * (shareholder.share * 1000000 / resource.sharesSum) / 1000000);
        }
    }
    
    /*function remove(uint256 resourceId) public providerOnly(resourceId) {
        // todo invalidate resource
    }*/
    
    function destroyContract() public ownerOnly {
        selfdestruct(owner);
    }
}