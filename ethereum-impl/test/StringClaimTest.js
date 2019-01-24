const SimpleIssuer = artifacts.require("SimpleIssuer");
const ClaimInspectorDemo = artifacts.require("ClaimInspectorDemo");
const PassportScheme = artifacts.require("PassportScheme");

contract("StringClaimTest", async accounts => {

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

    it("Check Claim nationality", async () => {
        prop = web3.utils.fromAscii("nationality")
        value = web3.utils.fromAscii("CHE")

        let hashedClaim = await injectClaim(
            issuer1, 
            holder1, 
            prop, 
            value);

        let result = await claimInspector.protectedMethod(
            hashedClaim,
            {from: holder1});

        assert.equal(result.logs[0].event, "LoggedIn")
    });

    it("requireSpecificClaim - Nationality", async () => {
        prop = web3.utils.fromAscii("nationality")
        value = web3.utils.fromAscii("CHE")

        let hashedClaim = await injectClaim(
            issuer1, 
            holder1, 
            prop, 
            value);

        let result = await claimInspector.requireSpecificClaim({from: holder1});

        assert.equal(result.logs[0].event, "LoggedIn")
    });

    it("requireSpecificClaim - Claim not available", async () => {
        prop = web3.utils.fromAscii("nationality")
        value = web3.utils.fromAscii("CHE")

        let hashedClaim = await injectClaim(
            issuer1, 
            holder1, 
            prop, 
            value);

        try {
            let result = await claimInspector.requireSpecificClaim({from: holder2});
            assert.fail("Exception expected a line before!")
        } catch (ex) {
            assert.include(ex.toString(), "revert Claim not found");
        }
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