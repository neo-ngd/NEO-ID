const SimpleIssuer = artifacts.require("SimpleIssuer");
const ClaimInspectorDemo = artifacts.require("ClaimInspectorDemo");
const PassportScheme = artifacts.require("PassportScheme");


contract("BasicClaimTest", async accounts => {

    let simpleIssuer;
    let claimInspector;
    let scheme;

    let issuer1 = accounts[0];
    let holder1 = accounts[1];
    let holder2 = accounts[2];

    beforeEach(async () => {
        simpleIssuer = await SimpleIssuer.new();
        scheme = await PassportScheme.new();
        claimInspector = await ClaimInspectorDemo.new(simpleIssuer.address, issuer1, scheme.address);
    });

    it("Assign Claim", async () => {
        prop = web3.utils.fromAscii("nationality")
        value = web3.utils.fromAscii("CHE")

        await injectClaim(issuer1, holder1, prop, value);
    });

    it("Get Claim Property", async () => {
        prop = web3.utils.fromAscii("nationality");
        value = web3.utils.fromAscii("CHE");

        let hashedClaim = await injectClaim(issuer1, holder1, prop, value);

        let retArray = await simpleIssuer.getClaimByHash(hashedClaim);
        let actualValue = retArray[4];
        strActualValue = web3.utils.toAscii(actualValue);
        strActualValue = strActualValue.replace(/\0/g, '');

        assert.equal(strActualValue, "CHE");
    });

    async function injectClaim(issuer, holder, property, value) {
        let hash = await simpleIssuer.calcHash(
            issuer,
            holder, 
            scheme.address, 
            property, 
            value);

        let signedHash = await web3.eth.sign(hash, issuer);

        let result = await simpleIssuer.injectClaim(
            issuer,
            holder, 
            scheme.address, 
            property, 
            value,
            signedHash,
            {from: issuer});
        
        let actualHolder = result.logs[0].args.holder;
        let actualIssuer = result.logs[0].args.issuer;
        let hashedClaim = result.logs[0].args.hashedClaim;
        assert.equal(result.logs[0].event, "ClaimIssued")
        assert.equal(actualHolder, holder);
        assert.equal(actualIssuer, issuer);
        return hashedClaim;
    }
});