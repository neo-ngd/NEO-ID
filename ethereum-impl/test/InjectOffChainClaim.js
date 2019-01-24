const SimpleIssuer = artifacts.require("SimpleIssuer");
const ClaimInspectorDemo = artifacts.require("ClaimInspectorDemo");
const PassportScheme = artifacts.require("PassportScheme");

contract("InjectOffChainClaim", async accounts => {

    let simpleIssuer;
    let claimInspector;
    let scheme;

    let issuer1 = accounts[0];
    let holder1 = accounts[1];
    let holder2 = accounts[2];
    let injector = accounts[3];

    beforeEach(async () => {
        simpleIssuer = await SimpleIssuer.new();
        scheme = await PassportScheme.new();
        claimInspector = await ClaimInspectorDemo.new(simpleIssuer.address, issuer1, scheme.address);
    });

    it("injectSignedClaim", async () => {
        prop = web3.utils.fromAscii("nationality")
        value = web3.utils.fromAscii("CHE")

        let hash = await simpleIssuer.calcHash(
            issuer1,
            holder1, 
            scheme.address, 
            prop, 
            value);

        let signedHash = await web3.eth.sign(hash, issuer1);

        let result = await simpleIssuer.injectClaim(
            issuer1,
            holder1, 
            scheme.address, 
            prop, 
            value, 
            signedHash,
            {from: injector});

        let actualHolder = result.logs[0].args.holder;
        let actualIssuer = result.logs[0].args.issuer;
        let hashedClaim = result.logs[0].args.hashedClaim;
        assert.equal(result.logs[0].event, "ClaimIssued")
        assert.equal(actualHolder, holder1);
        assert.equal(actualIssuer, issuer1);
        assert.equal(hashedClaim, hash)

        result = await claimInspector.protectedMethod(
            hashedClaim,
            {from: holder1});

        assert.equal(result.logs[0].event, "LoggedIn")
    });
});