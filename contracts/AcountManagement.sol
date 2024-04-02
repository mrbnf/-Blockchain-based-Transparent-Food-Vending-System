// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
contract AcountManagement {
enum JobType {
farmer,
wholesaler,
retailer,
customer

}

struct Acount {
address owner;
string password;
JobType job;
}

mapping (string => Acount) public acountsList;
mapping (string => bool) public acountExist;


function createAcount (string memory _userName,string memory _password,JobType _job) public {
    require(acountExist[_userName  ]== false,'change username');
    acountExist[_userName]= true;
    acountsList[_userName]= Acount({owner:msg.sender,password:_password,job:_job});  
}
function login (string calldata _userName,string calldata _password) external view returns (bool) {
if (acountExist[_userName]== false) {
    return false;
}

 if (keccak256(abi.encodePacked(acountsList[_userName].password)) != keccak256(abi.encodePacked(_password))) {
    return false;
}
if (keccak256(abi.encodePacked(acountsList[_userName].password)) == keccak256(abi.encodePacked(_password))) {
    return true;
}
return false;
}

}