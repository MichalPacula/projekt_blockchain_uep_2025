const fs = require("fs");
const path = require("path");
const Web3 = require("web3");
const solc = require("solc");

const web3 = new Web3("http://127.0.0.1:7545");

const accountsData = JSON.parse(fs.readFileSync("accounts.json", "utf-8"));
const deployAccount = accountsData.account;
const privateKey = accountsData.privateKey;

const contractPath = "TicketNFT.sol";

const source = fs.readFileSync(contractPath, "utf-8");

const input = {
    language: "Solidity",
    sources: {
        [contractPath]: { content: source },
    },
    settings: {
        optimizer: {
            enabled: true,
            runs: 200
        },
        outputSelection: {
            "*": {
                "*": ["abi", "evm.bytecode"],
            },
        },
    },
};

const output = JSON.parse(
  solc.compile(JSON.stringify(input), {
    import: function (path) {
      try {
        return {
          contents: fs.readFileSync("node_modules/" + path, "utf8"),
        };
      } catch (e) {
        return { error: "Nie znaleziono: " + path };
      }
    },
  })
);

const contractFile = output.contracts[contractPath]["TicketNFT"];
const abi = contractFile.abi;
const bytecode = contractFile.evm.bytecode.object;

async function deploy() {
    const contract = new web3.eth.Contract(abi);

    const deployTX = contract.deploy({
        data: "0x" + bytecode,
        arguments: [web3.utils.toBN(web3.utils.toWei("0.01", "ether"))],
    });

    const signedTx = await web3.eth.accounts.signTransaction(
        {
            from: deployAccount,
            data: deployTX.encodeABI(),
            gas: 2000000,
        },
        privateKey
    );

    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log("Contract deployed under address: ", receipt.contractAddress);

    fs.writeFileSync("abi.json", JSON.stringify(abi, null, 2));
    fs.writeFileSync("address.txt", receipt.contractAddress);
}

deploy();