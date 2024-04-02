// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;
contract SupplyChain  {


event ProductLocation(uint indexed productId,  string location);
event ProductAdded(address indexed owner,uint  productId);
event ProductBuyed(address indexed owner,address indexed receiver,uint  productId);
uint public finalID=1000; 
string[] public productTypes=["Potatoes","Tomatoes","Strawberries","Plums","Peaches","Eggplant","Cucumber","Figs","Onions","Apples","Cherries","Broccoli","Grapes","Kiwi","Lemons","Oranges","Spinach","Carrots","Lettuce","Apricots"];

mapping (uint => productListData)  farmersProductByType;
mapping (uint => productListData)  wholesalersProductByType;
mapping (uint => productListData)  retailersProductByType;
mapping(uint => ProductData) public productsData ;
mapping (address => farmersData)  farmers;
mapping (address => wholeSalerRetailerData )  wholesalers;
mapping (address => wholeSalerRetailerData)  retailers;
mapping (address => customerData)  customers;
mapping (address => string) public usersJobType;
struct customerData{

uint[] toReceive;
}
struct farmersData{   
uint[] productForSale;

uint[] toSend;
}
struct wholeSalerRetailerData{ 
uint[] productForSale;

uint[] stock;
uint[] toReceive;
uint[] toSend;
}
struct productListData{
   
uint[] productList;
}
struct ProductData {
address owner;
uint parent;
uint productType ;
uint amount;
uint amountRemaining;
bool isForSale;
uint price;
uint minQuantity;
uint date;



}




function getHash(string memory str) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(str));
        
    }

function indexInListProduct(string memory productType) public view returns ( uint){
        bool bol;
        uint ind;
        (bol,ind)= retreiveIndexString(productTypes,productType);
        return ind;
    }


    function farmerConfirmSending(uint productId, bytes memory signature,address coinAddress) public { 
    
    ProductData memory product= productsData[productId];
    address wholeSalerOwner = product.owner;
    
    ProductData memory parentProduct= productsData[product.parent];
    address farmerBuyer = parentProduct.owner;
    MyCoin( coinAddress).transfertWithSignature(farmerBuyer,wholeSalerOwner,signature, productId);

    bool bol;
    uint ind;
    bool bool2;
    uint ind2;
    (bol,ind)=retreiveIndex(farmers[farmerBuyer].toSend,productId);
    (bool2,ind2)=retreiveIndex(wholesalers[wholeSalerOwner].toReceive,productId);
    if (bol && bol){
            farmers[farmerBuyer].toSend[ind]=farmers[farmerBuyer].toSend[farmers[farmerBuyer].toSend.length-1];
            farmers[farmerBuyer].toSend.pop(); 
            wholesalers[wholeSalerOwner].toReceive[ind]=wholesalers[wholeSalerOwner].toReceive[wholesalers[wholeSalerOwner].toReceive.length-1];
            wholesalers[wholeSalerOwner].toReceive.pop();
            wholesalers[wholeSalerOwner].stock.push(productId);
            emit ProductBuyed( msg.sender,product.owner,productId);  
        }
    
    
    }
    function wholeSalerConfirmSending(uint productId, bytes memory signature,address coinAddress) public { 
    
    ProductData memory product= productsData[productId];
    address RetailerOwner = product.owner;
    
    ProductData memory parentProduct= productsData[product.parent];
    address wholeSalerBuyer = parentProduct.owner;
        MyCoin( coinAddress).transfertWithSignature(wholeSalerBuyer,RetailerOwner,signature, productId);

    bool bol;
    uint ind;
    bool bool2;
    uint ind2;
    (bol,ind)=retreiveIndex(wholesalers[wholeSalerBuyer].toSend,productId);
    (bool2,ind2)=retreiveIndex(retailers[RetailerOwner].toReceive,productId);
    if (bol && bol){
            wholesalers[wholeSalerBuyer].toSend[ind]=wholesalers[wholeSalerBuyer].toSend[wholesalers[wholeSalerBuyer].toSend.length-1];
            wholesalers[wholeSalerBuyer].toSend.pop(); 
            retailers[RetailerOwner].toReceive[ind]=retailers[RetailerOwner].toReceive[retailers[RetailerOwner].toReceive.length-1];
            retailers[RetailerOwner].toReceive.pop();
            retailers[RetailerOwner].stock.push(productId); 
            emit ProductBuyed( msg.sender,product.owner,productId);
        }
         

    }
    function retailerConfirmSending(uint productId, bytes memory signature,address  coinAddress) public { 
        
    ProductData memory product= productsData[productId];
    address customerOwner = product.owner;
    
    ProductData memory parentProduct= productsData[product.parent];
    address retailerBuyer = parentProduct.owner;
    MyCoin( coinAddress).transfertWithSignature(retailerBuyer,customerOwner,signature, productId);
    bool bol;
    uint ind;
    bool bool2;
    uint ind2;
    (bol,ind)=retreiveIndex(retailers[retailerBuyer].toSend,productId);
    (bool2,ind2)=retreiveIndex(customers[customerOwner].toReceive,productId);
    if (bol && bol){
            retailers[retailerBuyer].toSend[ind]=retailers[retailerBuyer].toSend[retailers[retailerBuyer].toSend.length-1];
            retailers[retailerBuyer].toSend.pop(); 
            customers[customerOwner].toReceive[ind]=customers[customerOwner].toReceive[customers[customerOwner].toReceive.length-1];
            customers[customerOwner].toReceive.pop();
            emit ProductBuyed( msg.sender,product.owner,productId); 
        }
     

    }
    function buyProductWholesaler(uint productId,uint amount,address  coinAddress) public {
        finalID++; 
        ProductData memory parentProduct= productsData[productId];
        MyCoin(coinAddress).blockAmount(parentProduct.owner,msg.sender,finalID ,amount*parentProduct.price);
        
       
        productsData[productId].amountRemaining-=amount;
        uint parent =productId;
        productsData[finalID]=ProductData({owner:msg.sender,parent:parent ,productType:parentProduct.productType,amount:amount,amountRemaining:amount,isForSale:false,price:0,minQuantity:0,date:block.timestamp});
       // wholesalers[msg.sender].stock.push(finalID);
        wholesalers[msg.sender].toReceive.push(finalID);
        farmers[parentProduct.owner].toSend.push(finalID);
         if (productsData[productId].minQuantity >productsData[productId].amountRemaining ){
          productsData[productId].minQuantity =productsData[productId].amountRemaining;
        }
        if (productsData[productId].amountRemaining==0){
            bool bol;
            uint ind;
            bool bool2;
            uint ind2;
            (bol,ind)=retreiveIndex(farmers[productsData[productId].owner].productForSale,productId);
            (bool2,ind2)=retreiveIndex(farmersProductByType[productsData[productId].productType].productList,productId);
        if (bol){
            farmers[productsData[productId].owner].productForSale[ind]=farmers[productsData[productId].owner].productForSale[farmers[productsData[productId].owner].productForSale.length-1];
            farmers[productsData[productId].owner].productForSale.pop();
            
        }
         if (bool2){
            farmersProductByType[productsData[productId].productType].productList[ind2]=farmersProductByType[productsData[productId].productType].productList[farmersProductByType[productsData[productId].productType].productList.length-1];
             farmersProductByType[productsData[productId].productType].productList.pop();  
         }
        }    
       
    }
    function buyProductRetailer(uint productId,uint amount,address  coinAddress) public {
        finalID++;
        ProductData memory parentProduct= productsData[productId];
        MyCoin(coinAddress).blockAmount(parentProduct.owner,msg.sender,finalID ,amount*parentProduct.price);

        productsData[productId].amountRemaining-=amount;
        uint parent =productId;
        productsData[finalID]=ProductData({owner:msg.sender,parent:parent ,productType:parentProduct.productType,amount:amount,amountRemaining:amount,isForSale:false,price:0,minQuantity:0,date:block.timestamp});
        //retailers[msg.sender].stock.push(finalID);
        retailers[msg.sender].toReceive.push(finalID);
        wholesalers[parentProduct.owner].toSend.push(finalID);
         if (productsData[productId].minQuantity >productsData[productId].amountRemaining ){
productsData[productId].minQuantity =productsData[productId].amountRemaining;
        }
        if (productsData[productId].amountRemaining==0){
            bool bol;
            uint ind;
            bool bool2;
            uint ind2;
            (bol,ind)=retreiveIndex(wholesalers[productsData[productId].owner].productForSale,productId);
            (bool2,ind2)=retreiveIndex(wholesalersProductByType[productsData[productId].productType].productList,productId);
        if (bol){
            wholesalers[productsData[productId].owner].productForSale[ind]=wholesalers[productsData[productId].owner].productForSale[wholesalers[productsData[productId].owner].productForSale.length-1];
            wholesalers[productsData[productId].owner].productForSale.pop();
            
        }
         if (bool2){
            wholesalersProductByType[productsData[productId].productType].productList[ind2]=wholesalersProductByType[productsData[productId].productType].productList[wholesalersProductByType[productsData[productId].productType].productList.length-1];
             wholesalersProductByType[productsData[productId].productType].productList.pop();  
         }
        }  
        
    }
 function buyProductCustomers(uint productId,uint amount,address  coinAddress) public {
        finalID++;
        ProductData memory parentProduct= productsData[productId];
        MyCoin(coinAddress).blockAmount(parentProduct.owner,msg.sender,finalID ,amount*parentProduct.price);

        productsData[productId].amountRemaining-=amount;
        uint parent =productId;
        productsData[finalID]=ProductData({owner:msg.sender,parent:parent ,productType:parentProduct.productType,amount:amount,amountRemaining:amount,isForSale:false,price:0,minQuantity:0,date:block.timestamp});
        //customers[msg.sender].history.push(finalID);
        customers[msg.sender].toReceive.push(finalID);
        retailers[parentProduct.owner].toSend.push(finalID);
        if (productsData[productId].minQuantity >productsData[productId].amountRemaining ){
productsData[productId].minQuantity =productsData[productId].amountRemaining;
        }
        if (productsData[productId].amountRemaining==0){
            bool bol;
            uint ind;
            bool bool2;
            uint ind2;
            (bol,ind)=retreiveIndex(retailers[productsData[productId].owner].productForSale,productId);
            (bool2,ind2)=retreiveIndex(retailersProductByType[productsData[productId].productType].productList,productId);
        if (bol){
            retailers[productsData[productId].owner].productForSale[ind]=retailers[productsData[productId].owner].productForSale[retailers[productsData[productId].owner].productForSale.length-1];
            retailers[productsData[productId].owner].productForSale.pop();
            
        }
         if (bool2){
            retailersProductByType[productsData[productId].productType].productList[ind2]=retailersProductByType[productsData[productId].productType].productList[retailersProductByType[productsData[productId].productType].productList.length-1];
             retailersProductByType[productsData[productId].productType].productList.pop();  
         }
        }   
        
    }
    function farmersProductsListe(string memory pproductType) public view returns ( uint[] memory){
        uint ind =indexInListProduct(pproductType);
        return farmersProductByType[ind].productList;
    }
    function wholesalersProductsListe(string memory pproductType) public view returns ( uint[] memory){
        uint ind =indexInListProduct(pproductType);
        return wholesalersProductByType[ind].productList;
    }
    function retailersProductsListe(string memory pproductType) public view returns ( uint[] memory){
        uint ind =indexInListProduct(pproductType);
        return retailersProductByType[ind].productList;
    }

    function farmersProductsPersonal(address theFarmer,uint listType) public view returns ( uint[] memory){
        if(listType==1) {return farmers[theFarmer].productForSale;}
        else if(listType==3) {return farmers[theFarmer].toSend;}
        
        
    }

    function wholeSalerProductsPersonal(address wholeSaerAddr,uint listType) public view returns ( uint[] memory){
         if(listType==1) {return wholesalers[wholeSaerAddr].productForSale;}
        else if(listType==2) {return wholesalers[wholeSaerAddr].stock;}
        else if(listType==3) {return wholesalers[wholeSaerAddr].toSend;}
        else if(listType==4) {return wholesalers[wholeSaerAddr].toReceive;}
        
        
    }

    function retailerProductsPersonal(address retailerAddr,uint listType) public view returns ( uint[] memory){
         if(listType==1) {return retailers[retailerAddr].productForSale;}
        else if(listType==2) {return retailers[retailerAddr].stock;}
        else if(listType==3) {return retailers[retailerAddr].toSend;}
        else if(listType==4) {return retailers[retailerAddr].toReceive;}
        
        
    }
    function customerProductsPersonal(address theCustomer,uint listType) public view returns ( uint[] memory){
        
        
    if(listType==4) {return customers[theCustomer].toReceive;}
            
    }
    
    
   function modifyProduct(uint productId,uint amount,uint price,uint minQuantity)public {
        
         require(msg.sender==productsData[productId].owner,"you are not the owner");
         productsData[productId].price = price;
         productsData[productId].amountRemaining = amount;
         productsData[productId].minQuantity = minQuantity;
        
        
    }
    
    function farmerAddProduct(string memory pproductType,uint amount,uint price,uint minQuantity,string memory location)public {
        finalID++;
        uint ind =indexInListProduct(pproductType);
        farmersProductByType[ind].productList.push(finalID);
        
        

        
        productsData[finalID]=ProductData({owner:msg.sender,parent: 0,productType:ind,amount:amount,amountRemaining:amount,isForSale:true,price:price,minQuantity:minQuantity,date:block.timestamp});
        farmers[msg.sender].productForSale.push(finalID);
        emit ProductAdded(msg.sender ,finalID);
        emit  ProductLocation(finalID, location);
        
    }
   
    
    
   
   
     function wholeSalerFromStockToSale(uint productId,uint price,uint minQuantity,string memory _location)public {
        bool bol;
        uint ind;
        productsData[productId].price = price;
        emit  ProductLocation(productId, _location);
        
        productsData[productId].isForSale= true;
        productsData[productId].minQuantity = minQuantity;
        (bol,ind)=retreiveIndex(wholesalers[msg.sender].stock,productId);
        if (bol){
            wholesalers[msg.sender].stock[ind]=wholesalers[msg.sender].stock[wholesalers[msg.sender].stock.length-1];
            wholesalers[msg.sender].stock.pop();
            wholesalers[msg.sender].productForSale.push(productId);
            wholesalersProductByType[productsData[productId].productType].productList.push(productId);
        }
        emit ProductAdded(msg.sender,productId);
    }
    function retailerFromStockToSale(uint productId,uint price,uint minQuantity,string memory _location)public {
        bool bol;
        uint ind;
        productsData[productId].price = price;
        emit  ProductLocation(productId, _location);
        
        productsData[productId].isForSale= true;
        productsData[productId].minQuantity = minQuantity;
        (bol,ind)=retreiveIndex(retailers[msg.sender].stock,productId);
        if (bol){
            retailers[msg.sender].stock[ind]=retailers[msg.sender].stock[retailers[msg.sender].stock.length-1];
            retailers[msg.sender].stock.pop();
            retailers[msg.sender].productForSale.push(productId);
            retailersProductByType[productsData[productId].productType].productList.push(productId);
        }

        emit ProductAdded(msg.sender,productId);
    }
    function retreiveIndex(uint[] memory list,uint value) public pure returns(bool b,uint u){
        uint j=0;
    for (uint i = 0; i < list.length; i++) {
        if (list[i]==value){
            b=true;
            u=i;
            break;
        }  
        j++;
    }
    if (j==list.length){
        b=false;
            u=j;
    }
    }
    function compareStrings(string memory a, string memory b) public pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
}
    function retreiveIndexString(string[] memory list,string memory value) public pure returns(bool b,uint u){
        uint j=0;
    for (uint i = 0; i < list.length; i++) {
        if (compareStrings(list[i],value)){
            b=true;
            u=i;
            break;
        }  
        j++;
    }
    if (j==list.length){
        b=false;
            u=j;
    }
    }
    function productDatafromList( uint[] memory _productsId) public view returns ( ProductData[] memory){
        ProductData[] memory productssData = new  ProductData[](_productsId.length);
        for (uint i = 0; i < _productsId.length; i++) {
            
            ProductData storage productProgress = productsData[_productsId[i]];
            productssData[i] = productProgress;
    }
    return productssData;
    } 
    
}

contract MyCoin  {
mapping(address => uint) public balanceOf;
mapping(address=>toSend) public balanceToSend;
mapping(address=>toReceive) public balanceToReceive;
address public owner;
struct toSend{
mapping (string => uint) keyAmount;
uint total;
}
struct toReceive{
mapping (string => uint) keyAmount;
uint total;
}

constructor () public {
owner=msg.sender;

}

function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    function getHash(string memory str) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(str));
        
    } 
    function getEthSignedHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
    function verify(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
    function splitSignature(bytes memory sig) internal pure returns ( bytes32, bytes32,uint8)
    {
    require(sig.length == 65);
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
        
        r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := byte(0, mload(add(sig, 96)))
    }
    return (r, s, v);
    }

function transfert(address receiver,uint amount) public returns(bool){
    balanceOf[msg.sender]-=amount;
    balanceOf[receiver]+=amount;
    return true;
}

function mint(address receiver,uint amount) public {
    require(owner==msg.sender,"you are not the owner");
    balanceOf[ receiver]+=amount;
}



function transfertWithSignature(address receiver,address sender,bytes memory _signature,uint productId) public returns(bool){
    bytes32 hash = getHash(toString(productId));
    bytes32 ethSignHash = getEthSignedHash(hash);
    address signerAddress = verify(ethSignHash, _signature);
    //ProductData memory product= productsData[productId];
    //address wholeSalerOwner = product.owner;
   // require(signerAddress==wholeSalerOwner, "invalide signature");
    require(signerAddress== sender,"signer are not the sender in input");
    balanceOf[receiver]+=balanceToReceive[receiver].keyAmount[toString(productId)];
    balanceToReceive[receiver].total-=balanceToReceive[receiver].keyAmount[toString(productId)];
    balanceToReceive[receiver].keyAmount[toString(productId)]=0;
    balanceToSend[sender].total-=balanceToSend[sender].keyAmount[toString(productId)];
    balanceToSend[sender].keyAmount[toString(productId)]=0;
    
    return true;
}

function blockAmount(address receiver,address sender,uint productId ,uint amount) public {
require(balanceOf[sender]>= amount,"you dont have money");
balanceOf[sender]-=amount;
balanceToReceive[receiver].total+=amount;
balanceToReceive[receiver].keyAmount[toString(productId)]=amount;
balanceToSend[sender].keyAmount[toString(productId)]=amount;
balanceToSend[sender].total+=amount;

}

function balance(address retailerAddr) public view returns ( uint ){
        return balanceOf[retailerAddr];
    }
    function balanceToReceiveBlocked(address retailerAddr) public view returns ( uint){
        return balanceToReceive[retailerAddr].total ;
    }
    function balanceToSendBlocked(address retailerAddr) public view returns ( uint){
        return balanceToSend[retailerAddr].total ;
    }

}