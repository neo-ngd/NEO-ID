pragma solidity ^0.5.0;

/**
  * @title Scheme Interface
  * @author kasimir.blaser@swisscom.com
  * @notice Minimal interface representing a scheme
  */
contract Scheme {

    /**
      * @dev Checks if the property is valid
      * @param _property the property to validate
      * @return a boolean true if the property exists
      */
    function isValidProperty(bytes32 _property) public view returns (bool);
}