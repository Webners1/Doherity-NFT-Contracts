const hre = require('hardhat');
const apis = require('../data/apis.json');
const airnodeProtocol = require('@api3/airnode-protocol');
const amounts = {
    goerli: { value: 0.1, unit: 'ETH' },
    mainnet: { value: 0.05, unit: 'ETH' },
    arbitrum: { value: 0.01, unit: 'ETH' },
    avalanche: { value: 0.2, unit: 'AVAX' },
    bsc: { value: 0.003, unit: 'BNB' },
    fantom: { value: 1, unit: 'FTM' },
    gnosis: { value: 1, unit: 'xDAI' },
    metis: { value: 0.01, unit: 'METIS' },
    milkomeda: { value: 1, unit: 'milkADA' },
    moonbeam: { value: 0.1, unit: 'GLMR' },
    moonriver: { value: 0.01, unit: 'MOVR' },
    optimism: { value: 0.01, unit: 'ETH' },
    polygon: { value: 10, unit: 'MATIC' },
    rsk: { value: 0.0001, unit: 'RBTC' },
};
async function main() {
    const apiData = apis['ANU Quantum Random Numbers'];
    const airnodeRrpAddress = airnodeProtocol.AirnodeRrpAddresses[await hre.getChainId()];
    const qrngRandom = await hre.deployments.deploy('QrngRandom', {
        args: [airnodeRrpAddress],
        from: (await getUnnamedAccounts())[0],
        log: true,
    });
    console.log(`Deployed qrngRandom at ${qrngRandom.address}`);

    const sponsorWalletAddress = await airnodeAdmin.deriveSponsorWalletAddress(
        apiData.xpub,
        apiData.airnode,
        qrngRandom.address
    );

    // Set the parameters that will be used to make Airnode requests
    const receipt = await qrngRandom.setRequestParameters(
        apiData.airnode,
        apiData.endpointIdUint256,
        apiData.endpointIdUint256Array,
        sponsorWalletAddress
    );
    const amountInEther = amounts[hre.network.name].value;
    receipt = await account.sendTransaction({
        to: sponsorWalletAddress,
        value: hre.ethers.utils.parseEther(amountInEther.toString()),
    });
    console.log(
        `Funding sponsor wallet at ${sponsorWalletAddress} with ${amountInEther} ${amounts[hre.network.name].unit}...`
    );
    let NFT = await ethers.getContractFactory("AaronNFT")


    NFT = await NFT.deploy(qrngRandom.address)

    await NFT.deployed()

    // await NFT.filterDailyList()
    console.log("NFT:", NFT.address)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })