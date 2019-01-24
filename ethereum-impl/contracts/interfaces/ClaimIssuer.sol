pragma solidity ^0.5.0;

/**
  * @title ClaimIssuer Interface
  * @author kasimir.blaser@swisscom.com
  * @notice Minimal interface to issue and verify claims
  */
contract ClaimIssuer {

    /**
      * @dev Claim issuer issues a claim to a holder. 
      * @dev The interface is designed that off-chain claims can be injected.
      * @dev In case of a failure the transaction has to be reverted
      * @param _issuer the claim issuer
      * @param _holder the holder of the claim
      * @param _scheme the referenced scheme used for the claim
      * @param _property the claim property
      * @param _value the assigned value
      * @param _issuerSig the issuer signature over the hashed properties
      * @return a boolean true if inject was successful
      * @return a bytes32 representing the hash of the claim
      */
    function injectClaim(
        address _issuer,
        address _holder, 
        address _scheme, 
        bytes32 _property, 
        bytes32 _value,
        bytes memory _issuerSig
    )
        public 
        returns (bool success, bytes32 hashedClaim);

    /**
      * @dev Reading the hashed claim queried by its properties.
      * @dev With the hash of a claim further checks and validation can be done.
      * @dev In case of a failure the transaction has to be reverted
      * @param _issuer the claim issuer
      * @param _holder the holder of the claim
      * @param _scheme the referenced scheme used for the claim
      * @param _property the claim property
      * @return a bytes32 representing the hash of the claim
      */
    function getHashedClaimByProps(
        address _issuer, 
        address _holder, 
        address _scheme, 
        bytes32 _property
    ) 
        public view 
        returns (bytes32 hashedClaim);

    /**
      * @dev Reads all properties of a specific claim queried by its hash
      * @dev In case of a failure the transaction has to be reverted
      * @param _hashedClaim the hash of the claim
      * @return all properties of the claim
      */
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
            // bool isValid
        );

    /**
      * @dev A smart contract can call this function to verify if a hash of a claim is valid
      * @param _hashedClaim the hash of the claim
      * @return success if the claim exists and is active
      */
    function isValidHash(
        bytes32 _hashedClaim
    ) 
        public view 
        returns (bool success);

    /**
      * @dev A smart contract can call this function to verify the claim AND checks if all properties matches.
      * @param _issuer the claim issuer
      * @param _holder the holder of the claim
      * @param _scheme the referenced scheme used for the claim
      * @param _property the claim property
      * @return returns the assigned value of the claim
      */
    function validateClaimAndGetValue(
        address _issuer,
        address _holder, 
        address _scheme, 
        bytes32 _property
    )
        public view
        returns (bytes32 value);

    // TODO: There could be more functions defined. Such as Revokate Claims etc.. 
}