pragma solidity ^0.5.0;

import "./interfaces/Scheme.sol";

/**
  * @title PassportScheme
  * @author kasimir.blaser@swisscom.com
  * @notice Scheme implementation example. A Scheme which represent a passport. 
  */
contract PassportScheme is Scheme {

    address public owner;
    mapping(bytes32 => bool) public propertyMap;

    constructor() public {
        owner = msg.sender;
        propertyMap["name"] = true;
        propertyMap["sex"] = true;
        propertyMap["birthDate"] = true;
        propertyMap["nationality"] = true;
        propertyMap["passportNbr"] = true;
        propertyMap["issueDate"] = true;
        propertyMap["validDate"] = true;
    }

    function isValidProperty(
        bytes32 _property
    )
        public view
        returns (bool)
    {
        return propertyMap[_property];
    }
}