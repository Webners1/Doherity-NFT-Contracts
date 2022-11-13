async function main() {
    let DailyLottery = await ethers.getContractFactory("DailyFrinkLottery")
    const ROUTER_ADDRESS = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    const USDT_ADDRESS = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

   
   DailyLottery =  await DailyLottery.deploy("0x71771E820a9414b5f415b7f14D51701502C1F753",USDT_ADDRESS)

   await DailyLottery.deployed()
   await DailyLottery.filterDailyList()

    // await DailyLottery.filterDailyList()
   console.log("DailyLottery:",DailyLottery.address)
  }

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })