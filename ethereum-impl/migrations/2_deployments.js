var SimpleIssuer = artifacts.require("./SimpleIssuer.sol");
var ClaimInspectorDemo = artifacts.require("./ClaimInspectorDemo.sol");
var PassportScheme = artifacts.require("./PassportScheme.sol");

module.exports = function(deployer, network, accounts) {
  console.log("Deploy Contracts");
  deployer.then(async() => {
    console.log("Start deploying...");

    simpleIssuer = await deployer.deploy(SimpleIssuer);
    scheme = await deployer.deploy(PassportScheme);

    claimInspectorDemo = await deployer.deploy(
        ClaimInspectorDemo, 
        simpleIssuer.address, 
        accounts[0],
        scheme.address); 
  });
};