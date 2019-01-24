const SimpleIssuer = artifacts.require("SimpleIssuer");
const ClaimInspectorDemo = artifacts.require("ClaimInspectorDemo");
const PassportScheme = artifacts.require("PassportScheme");

contract("NumberClaimTest", async accounts => {

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


    it("Check Claim birthDate - over 18", async () => {
        prop = web3.utils.fromAscii("birthDate")
        //1990-01-01 = 631152000 dez = 259E9D80 hex
        value = web3.utils.hexToBytes("0x00000000000000000000000000000000000000000000000000000000259E9D80") //unix timestamp 1990-01-01

        let hashedClaim = await injectClaim(
            issuer1,
            holder1,
            prop,
            value);

        let result = await claimInspector.onlyAdult(
            hashedClaim, {
                from: holder1
            });

        assert.equal(result.logs[0].event, "LoggedIn")
    });

    it("Check Claim birthDate - NOT over 18", async () => {
        prop = web3.utils.fromAscii("birthDate")
        //2019-01-01 = 1546300800 dez = 5C2AAD80 hex
        value = web3.utils.hexToBytes("0x000000000000000000000000000000000000000000000000000000005C2AAD80") //unix timestamp 1990-01-01

        let hashedClaim = await injectClaim(
            issuer1,
            holder1,
            prop,
            value);

        try {
            let result = await claimInspector.onlyAdult(
                hashedClaim, {
                    from: holder1
                });

            assert.fail("Exception expected a line before!")
        } catch (ex) {
            assert.include(ex.toString(), "revert Not yet 18 years old");
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