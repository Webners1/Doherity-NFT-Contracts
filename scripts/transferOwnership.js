const contractAddress = "0xd4b86Ee9C8776954457Ff3C85Bd441AF9a3d3e0b";
const daily = await hre.ethers.getContractAt("DailyFrinkLottery", contractAddress);
const weekly = await hre.ethers.getContractAt("DailyFrinkLottery", contractAddress);
const newOwner = ""
const dailyHash = await daily.transferOwnership(newOwner);
const WeeklyHash = await weekly.transferOwnership(newOwner);

console.log("daily owner:", await daily.manager())
console.log("weekly owner:", await weekly.manager())
console.log("Trx hash:", dailyHash.hash);
console.log("Trx hash:", WeeklyHash.hash);