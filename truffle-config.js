module.exports = {
  networks: {
    development: {
      host: "192.168.43.240",
      port: 8545,
      network_id: "*",
      
      
    },
    advanced: {
      websockets: true, // Enable EventEmitter interface for web3 (default: false)
    },
  },
  contracts_build_directory: "assets/src/abis/",
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};