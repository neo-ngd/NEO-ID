pragma solidity ^0.5.0;

import "./interfaces/Scheme.sol";
import "./interfaces/ClaimIssuer.sol";

/**
  * @title SimpleIssuer
  * @author kasimir.blaser@swisscom.com
  * @notice ClaimIssuer implementation example. Demonstrates a simple issuer. 
  */
contract SimpleIssuer is ClaimIssuer {

    struct Claim {
        address issuer;
        address holder;
        address scheme;
        bytes32 property;
        bytes32 value;
        bytes issuerSig; // not part of the Claim
    }

    //map bytes32 represents the hash of: issuer+holder+scheme+property+value
    mapping(bytes32 => Claim) private claimMap;

    //issuer > holder > scheme > property returns hash
    mapping(address => mapping(address => mapping(address => mapping(bytes32 => bytes32)))) private claimPropMap;

    event ClaimIssued(
        address indexed issuer,
        address indexed holder,
        bytes32 hashedClaim
    );

    constructor() public { }

    function injectClaim(
        address _issuer,
        address _holder, 
        address _scheme, 
        bytes32 _property, 
        bytes32 _value,
        bytes memory _issuerSig
    )
        public
        returns (bool success, bytes32 hashedClaim)
    {
        hashedClaim = calcHash(_issuer, _holder, _scheme, _property, _value);
        address issuer = recoverSigner(hashedClaim, _issuerSig);
        require(issuer == _issuer, "Issuer address doesn't match the signer");
        
        hashedClaim = calcHash(_issuer, _holder, _scheme, _property, _value);

        require(claimMap[hashedClaim].issuer == address(0x0), "Claim already exists!");

        require(Scheme(_scheme).isValidProperty(_property), "Scheme contract not found or property not valid");

        claimMap[hashedClaim].issuer = _issuer;
        claimMap[hashedClaim].holder = _holder;
        claimMap[hashedClaim].scheme = _scheme;  //TODO: check if scheme exists as smart contract
        claimMap[hashedClaim].property = _property; //TODO: check if it's a valid property in scheme
        claimMap[hashedClaim].value = _value;
        claimMap[hashedClaim].issuerSig = _issuerSig;

        success = true;

        claimPropMap[_issuer][_holder][_scheme][_property] = hashedClaim;
        emit ClaimIssued(_issuer, _holder, hashedClaim);
    }

    function getHashedClaimByProps(
        address _issuer, 
        address _holder, 
        address _scheme, 
        bytes32 _property
    ) 
        public view 
        returns (bytes32 hashedClaim)
    {
        hashedClaim = claimPropMap[_issuer][_holder][_scheme][_property];
        require(uint256(hashedClaim) != 0x0, "Claim not found");
    }

    function getClaimByHash(
        bytes32 _hashedClaim
    ) 
        public view 
        returns (
            address issuer,
            address holder,
            address scheme,
            bytes32 property,
            bytes32 value,
            bytes memory issuerSig
        )
    {
        issuer = claimMap[_hashedClaim].issuer;
        require(issuer != address(0x0), "Claim not found");

        holder = claimMap[_hashedClaim].holder;
        scheme = claimMap[_hashedClaim].scheme;
        property = claimMap[_hashedClaim].property;
        value = claimMap[_hashedClaim].value;
        issuerSig = claimMap[_hashedClaim].issuerSig;
    }

    function isValidHash(
        bytes32 _hashedClaim
    ) 
        public view 
        returns (bool success)
    {
        require(claimMap[_hashedClaim].issuer != address(0x0), "Claim not found");
        //TODO: Check for expire, revoke, etc...
        success = true;
    }

    function validateClaimAndGetValue(
        address _issuer,
        address _holder, 
        address _scheme, 
        bytes32 _property
    )
        public view
        returns (bytes32 value)
    {
        bytes32 hashedClaim = getHashedClaimByProps(_issuer, _holder, _scheme, _property);

        require(isValidHash(hashedClaim), "Claim not found");
        require(_issuer == claimMap[hashedClaim].issuer, "Issuer not match");
        require(_holder == claimMap[hashedClaim].holder, "Holder not match");   
        require(_scheme == claimMap[hashedClaim].scheme, "Scheme not match");   
        require(_property == claimMap[hashedClaim].property, "Property not match");   

        value = claimMap[hashedClaim].value;
    }

    function calcHash(
        address _issuer, 
        address _holder, 
        address _scheme, 
        bytes32 _property, 
        bytes32 _value
    ) 
        public pure 
        returns (bytes32 hashedClaim) 
    {  
        bytes memory encoded = abi.encodePacked(_issuer, _holder, _scheme, _property, _value);
        hashedClaim = keccak256(encoded);
    }

    /**
      * @dev Recover signer address from a message by using their signature
      * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
      * @param sig bytes signature, the signature is generated using web3.eth.sign(). Inclusive "0x..."
      */
    function recoverSigner(
        bytes32 hash, 
        bytes memory sig
    ) 
        private pure 
        returns (address) 
    {
        require(sig.length == 65, "Require correct length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        // Divide the signature in r, s and v variables
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Signature version not match");

        return recoverSigner2(hash, v, r, s);
    }

    function recoverSigner2(
        bytes32 h, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        private pure 
        returns (address) 
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, h));
        address addr = ecrecover(prefixedHash, v, r, s);

        return addr;
    }
}