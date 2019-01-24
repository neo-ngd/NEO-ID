pragma solidity ^0.5.0;

import "./interfaces/ClaimIssuer.sol";

/**
  * @title ClaimInspectorDemo
  * @author kasimir.blaser@swisscom.com
  * @notice This contracts demonstrates how to validate a "Claim" on-chain.
  */
contract ClaimInspectorDemo {

    ClaimIssuer public claimIssuer;
    address public trustedIssuer;
    address public scheme;

    uint256 private eighteenYear = 18 * 52 weeks;
    event LoggedIn();

    constructor(address _claimIssuer, address _trustedIssuer, address _scheme) 
        public 
    {
        claimIssuer = ClaimIssuer(_claimIssuer);
        trustedIssuer = _trustedIssuer;
        scheme = _scheme;
    }

    function requireSpecificClaim() 
        public 
        returns (bool allowed) 
    {
        bytes32 property = "nationality";
        
        bytes32 hashedClaim = claimIssuer.getHashedClaimByProps(
            trustedIssuer,
            msg.sender,
            scheme,
            property);
        
        ( , , , , bytes32 value, ) = claimIssuer.getClaimByHash(hashedClaim);
        require(value == "CHE", "Value not match!");

        // Critical section here

        allowed = true;
        emit LoggedIn();
    }

    function protectedMethod(bytes32 _hashedClaim) 
        public 
        returns (bool allowed) 
    {
        
        require(
            claimIssuer.isValidHash(_hashedClaim), 
            "Hash not valid"
        );
        
        (address issuer, address holder, address scheme2, bytes32 property, bytes32 value, ) = claimIssuer.getClaimByHash(_hashedClaim);
        
        require(issuer == trustedIssuer, "Wrong issuer");
        require(holder == msg.sender, "Wrong holder");
        require(scheme2 == scheme, "Wrong scheme");
        require(property == "nationality", "Value not match!");
        require(value == "CHE", "Value not match!");

        // Critical section here

        allowed = true;
        emit LoggedIn();
    }

    function onlyAdult(bytes32 _hashedClaim)
        public 
        returns (bool allowed) 
    {
        bytes32 value = claimIssuer.validateClaimAndGetValue(trustedIssuer, msg.sender, scheme, "birthDate");
        uint256 birthDate = uint256(value);
        require(birthDate < now - eighteenYear, "Not yet 18 years old");

        // Critical section here

        allowed = true;
        emit LoggedIn();
    }
}