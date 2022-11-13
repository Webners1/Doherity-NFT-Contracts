async function main() {
    let Frinklock = await ethers.getContractFactory("FRINKLPLOCKCONTRACT")
    const LP_ADDRESS = "0x0B44E1001e40D3A9E25Bcd5537128D77C569eAa3"
    const BENEFICIARY_ADDRESS = "0x61bEE7b65F860Fe5a22958421b0a344a0F146983"
   Frinklock =  await Frinklock.deploy(LP_ADDRESS,BENEFICIARY_ADDRESS)

   await Frinklock.deployed()
   console.log("Frink LPLock:",Frinklock.address)

  }

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })