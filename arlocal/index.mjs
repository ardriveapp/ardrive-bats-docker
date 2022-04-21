import * as fs from 'fs'
import Sweets from 'arlocal-sweets';
import Arweave from 'arweave';

const walletFolder = "./wallets/"

const hostsFile = fs.readFileSync('/etc/hosts', 'utf8', (err, data) => {
    if (err) {
        console.error(err)
        return
    }
})

const storeWallet = (wallet, name) => {
    let jsonContent = JSON.stringify(wallet)
    let jsonWalletName = name + ".json"
    fs.writeFileSync(`${walletFolder}/${jsonWalletName}`, jsonContent, 'utf8', function (err) {
        if (err) {
            console.error("An error occured while writing JSON wallet to a File.")
            return console.log(err)
        }
    })
}
//Get last line from file.
let lastLine = hostsFile.trim().split('\n').slice(-1)[0]
//Get host from last line.
let host = lastLine.match(/^(\S+)\s(.*)/).slice(1)[0]
//Tansform into Subnet
let arlocalGW = host.slice(0, -1) + '1'

const arweave = new Arweave({
    host: arlocalGW,
    port: 1984,
    protocol: 'http'
});

const wallet = await arweave.wallets.generate()
const address = await arweave.wallets.jwkToAddress(wallet)
const sweets = new Sweets(arweave, wallet)

if (await sweets.isTestNetwork()) {
    //Fund with 100AR
    await sweets.fundWallet(100e12)
    console.log("Wallet funded successfully")
    storeWallet(wallet, address)
    console.log("Wallet file has been saved.")
    console.log("Wallet address:", address)

} else {
    console.error("Cannot reach Arlocal")
}
//missing setup ENV var and trigger
