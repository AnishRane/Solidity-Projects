pragma solidity ^0.8.0;

contract BloodBank{
    address admin;
    // set deployer as Admin of contract
    constructor(){
        admin = msg.sender;
    }
    
    // modifier for admin only operations
    modifier adminOnly(){
        require(msg.sender == admin,"Admin only call");
        _;
    }

    // Bloodgroup types enum
    enum Btype{
        A_positive,     // 0
        A_negative,     // 1
        B_postive,      // 2
        B_negative,     // 3
        O_positive,     // 4
        O_negative,     // 5
        AB_positive,    // 6
        AB_negative     // 7
    }

    // Used for storing user records
    struct User{
        address user_address;
        Btype bloodgroup;
        address[] donors;
    }

    // Array to store all user records
    // This array has also created to fetch all user records once
    User[] allusers;

    // Address to index mapping to fetch single users details from array
    mapping(address => uint) userMapping;

    // Address to bool mapping to prevent duplicate records entery
    mapping(address => bool) registered;

    // Used to notify if Txn is executed sucessfully
    event Successfull(string message);

    // Function to change admin 
    function setNewAdmin(address _newAdmin) external adminOnly{
        admin = _newAdmin;
    }

    // Function to register user into blood bank
    function registerUser(Btype _bloodgroup,address _user) public adminOnly{
        require(registered[_user] == false,"User already registered");
        uint index = allusers.length;
        allusers.push();
        allusers[index].user_address = _user;
        allusers[index].bloodgroup = _bloodgroup;
        userMapping[_user] = index;
        registered[_user] = true;
        emit Successfull ("User registered sucessfully");
    }

    // Function to get all user details
    function getAllUsers() public view adminOnly returns(User[] memory){
        return allusers;
    }

    // Function for user to fetch his/hers user details
    function getUserDetail(address _user) external view adminOnly returns (User memory){
        uint _userIndex = userMapping[_user];
        return allusers[_userIndex];
    }

    // Function to donate blood , can be executed by admin
    function donateBlood( address _donor, address _receiver) external adminOnly{
        uint donor_index = userMapping[_donor];
        uint receiver_index = userMapping[_receiver];
        Btype _donorBgroup = allusers[donor_index].bloodgroup;
        Btype _receiverBgroup = allusers[receiver_index].bloodgroup;
        require(_donorBgroup == _receiverBgroup, "Blood group mismatch");
        allusers[receiver_index].donors.push(_donor);
        emit Successfull ("User registered sucessfully");
    }

    // Function to fetch list of donors, can be called by any user to fetch only thier details
    function getMyDonors() public view returns (address[] memory){
        uint user_index = userMapping[msg.sender];
        return allusers[user_index].donors;
    }

    // AdminOnly functions to fetch all donors for specific users
    function getUsersDonor(address _user) public view adminOnly returns(address [] memory){
        uint userIndex = userMapping[_user];
        return allusers[userIndex].donors;
    }
}
