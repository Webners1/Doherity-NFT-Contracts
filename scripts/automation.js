

// const LotteryAbiWeekly = [
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "contract FrinkTok",
// 				"name": "FrinkAddress",
// 				"type": "address"
// 			},
// 			{
// 				"internalType": "address",
// 				"name": "_USDTAddress",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "nonpayable",
// 		"type": "constructor"
// 	},
// 	{
// 		"anonymous": false,
// 		"inputs": [
// 			{
// 				"indexed": false,
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"name": "onLotteryEnd",
// 		"type": "event"
// 	},
// 	{
// 		"stateMutability": "payable",
// 		"type": "fallback"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"name": "AlreadyWon",
// 		"outputs": [
// 			{
// 				"internalType": "bool",
// 				"name": "",
// 				"type": "bool"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"name": "LOTTERYLIST",
// 		"outputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"name": "LotteryAddr",
// 		"outputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"name": "NEWLOTTERYLIST",
// 		"outputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "TOKEN_THRESHOLD",
// 		"outputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "USDTToken",
// 		"outputs": [
// 			{
// 				"internalType": "contract IERC20",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "acceptOwnership",
// 		"outputs": [],
// 		"stateMutability": "nonpayable",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "tokenthreshold",
// 				"type": "uint256"
// 			}
// 		],
// 		"name": "changeTokenThreshold",
// 		"outputs": [],
// 		"stateMutability": "nonpayable",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "day",
// 		"outputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "filterDailyList",
// 		"outputs": [],
// 		"stateMutability": "nonpayable",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "getLastWinner",
// 		"outputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "getPlayers",
// 		"outputs": [
// 			{
// 				"internalType": "address[]",
// 				"name": "",
// 				"type": "address[]"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "address",
// 				"name": "addr",
// 				"type": "address"
// 			}
// 		],
// 		"name": "isDailyReady",
// 		"outputs": [
// 			{
// 				"internalType": "bool",
// 				"name": "",
// 				"type": "bool"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "lastWinner",
// 		"outputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "manager",
// 		"outputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "minPlayers",
// 		"outputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "newManager",
// 		"outputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "pair",
// 		"outputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "pickDailyLotteryWinner",
// 		"outputs": [],
// 		"stateMutability": "nonpayable",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "tokenContract",
// 		"outputs": [
// 			{
// 				"internalType": "contract FrinkTok",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "address",
// 				"name": "_newManager",
// 				"type": "address"
// 			}
// 		],
// 		"name": "transferOwnership",
// 		"outputs": [],
// 		"stateMutability": "nonpayable",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"name": "winnerDetails",
// 		"outputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"name": "winners",
// 		"outputs": [
// 			{
// 				"internalType": "address",
// 				"name": "",
// 				"type": "address"
// 			}
// 		],
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"name": "withdrawToken",
// 		"outputs": [],
// 		"stateMutability": "nonpayable",
// 		"type": "function"
// 	}
// ]


// var Web3 = require('web3');
// PUBLIC_KEY= ""
// PRIVATE_KEY= ""
//  async function main() {
// var web3 = new Web3(new Web3.providers.HttpProvider('https://eth-mainnet.g.alchemy.com/v2/hK1w_lNLh9MOTnr5iZm2K_vOT8ZNYeXM'));
//   const contractAddress = "0x4b1d204dee2E91CF7e3a5CaaB97Dd0D5Af65CbD1";
// 	const LOTTERY_CONTRACT = await new web3.eth.Contract(LotteryAbiWeekly, contractAddress);
//     let nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, 'latest'); // get latest nonce
//     let gasEstimate = await LOTTERY_CONTRACT.methods.filterDailyList().estimateGas({from:PUBLIC_KEY}); // estimate gas
	
//   	console.log("running...")
//     // Create the transaction
//      let tx = {
//       'from': PUBLIC_KEY,
//       'to': contractAddress,
//       'nonce': nonce,
//       'gas': gasEstimate,
//       'data': LOTTERY_CONTRACT.methods.filterDailyList().encodeABI()
//     };
//     console.log(await LOTTERY_CONTRACT.methods.manager().call())
//     // Sign the transaction
//      let signPromise = await web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);

//       await web3.eth.sendSignedTransaction(signPromise.rawTransaction, function(err, hash) {
//         if (!err) {
//           console.log("The hash of your transaction is: ", hash, "\n Check Alchemy's Mempool to view the status of your transaction!");
//         } else {
//           console.log("Something went wrong when submitting your transaction:", err)
//         }
//       });
//        nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, 'latest'); // get latest nonce
  
//   gasEstimate = await LOTTERY_CONTRACT.methods.pickDailyLotteryWinner().estimateGas({from:PUBLIC_KEY}); // estimate gas
//      tx = {
//       'from': PUBLIC_KEY,
//       'to': contractAddress,
//       'nonce': nonce,
//       'gas': gasEstimate,
//       'data': LOTTERY_CONTRACT.methods.pickDailyLotteryWinner().encodeABI()
//     };
//     // Sign the transaction
//      signPromise = await web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);

//       await web3.eth.sendSignedTransaction(signPromise.rawTransaction, function(err, hash) {
//         if (!err) {
//           console.log("The hash of your transaction is: ", hash, "\n Check Alchemy's Mempool to view the status of your transaction!");
//         } else {
//           console.log("Something went wrong when submitting your transaction:", err)
//         }
//       });


// }
// main()

  
  const LotteryAbiWeekly = [
	{
	  "inputs": [
		{
		  "internalType": "address",
		  "name": "FrinkAddress",
		  "type": "address"
		},
		{
		  "internalType": "address",
		  "name": "_USDTAddress",
		  "type": "address"
		}
	  ],
	  "stateMutability": "nonpayable",
	  "type": "constructor"
	},
	{
	  "anonymous": false,
	  "inputs": [
		{
		  "indexed": false,
		  "internalType": "address",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "name": "onLotteryEnd",
	  "type": "event"
	},
	{
	  "stateMutability": "payable",
	  "type": "fallback"
	},
	{
	  "inputs": [],
	  "name": "USDTToken",
	  "outputs": [
		{
		  "internalType": "contract IERC20",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "acceptOwnership",
	  "outputs": [],
	  "stateMutability": "nonpayable",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "getLastWinner",
	  "outputs": [
		{
		  "internalType": "address",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "getPlayers",
	  "outputs": [
		{
		  "internalType": "address[]",
		  "name": "",
		  "type": "address[]"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "lastWinner",
	  "outputs": [
		{
		  "internalType": "address",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "manager",
	  "outputs": [
		{
		  "internalType": "address",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "minPlayers",
	  "outputs": [
		{
		  "internalType": "uint256",
		  "name": "",
		  "type": "uint256"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "newManager",
	  "outputs": [
		{
		  "internalType": "address",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "pickDailyLotteryWinner",
	  "outputs": [],
	  "stateMutability": "nonpayable",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "tokenAddress",
	  "outputs": [
		{
		  "internalType": "address",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [],
	  "name": "tokenContract",
	  "outputs": [
		{
		  "internalType": "contract ERC20TokenFrink",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [
		{
		  "internalType": "address",
		  "name": "_newManager",
		  "type": "address"
		}
	  ],
	  "name": "transferOwnership",
	  "outputs": [],
	  "stateMutability": "nonpayable",
	  "type": "function"
	},
	{
	  "inputs": [
		{
		  "internalType": "address",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "name": "winnerDetails",
	  "outputs": [
		{
		  "internalType": "uint256",
		  "name": "",
		  "type": "uint256"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	},
	{
	  "inputs": [
		{
		  "internalType": "uint256",
		  "name": "",
		  "type": "uint256"
		}
	  ],
	  "name": "winners",
	  "outputs": [
		{
		  "internalType": "address",
		  "name": "",
		  "type": "address"
		}
	  ],
	  "stateMutability": "view",
	  "type": "function"
	}
  ]
  
  
  var Web3 = require('web3');
  PUBLIC_KEY= "0xF1BC72cC7b8c9B711b46d2D1A2cE131c5F167772"
  PRIVATE_KEY= "03d5162912ce1fa888475222b82fb14337ea2d07401360632cb1887128659f16"
  exports.handler = async function(event) {
  var web3 = new Web3(new Web3.providers.HttpProvider('https://eth-mainnet.g.alchemy.com/v2/hK1w_lNLh9MOTnr5iZm2K_vOT8ZNYeXM'));
	const contractAddress = "0x4Daf84211F5DBbd7D88C11ED671FF18e7416e293";
	  const LOTTERY_CONTRACT = await new web3.eth.Contract(LotteryAbiWeekly, contractAddress);
	 
		 let nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, 'latest'); // get latest nonce
	
	let gasEstimate = await LOTTERY_CONTRACT.methods.pickDailyLotteryWinner(winner).estimateGas({from:PUBLIC_KEY}); // estimate gas
	   tx = {
		'from': PUBLIC_KEY,
		'to': contractAddress,
		'nonce': nonce,
		'gas': gasEstimate,
		'data': LOTTERY_CONTRACT.methods.pickDailyLotteryWinner().encodeABI()
	  };
	  // Sign the transaction
	   signPromise = await web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
  
		await web3.eth.sendSignedTransaction(signPromise.rawTransaction, function(err, hash) {
		  if (!err) {
			console.log("The hash of your transaction is: ", hash, "\n Check Alchemy's Mempool to view the status of your transaction!");
		  } else {
			console.log("Something went wrong when submitting your transaction:", err)
		  }
		});
  
  
  }
