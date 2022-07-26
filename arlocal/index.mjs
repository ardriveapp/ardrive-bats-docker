import * as fs from 'fs'
import * as path from 'path'
import Sweets from 'arlocal-sweets'
import Arweave from 'arweave'

const walletFolder = "./wallets/"
const envFilePath = "./bats-variables.env"

const getArlocalHost = async () => {
    try {
        const data = await fs.promises.readFile('/etc/hosts', 'utf8')
        //Get last line from file.
        let lastLine = data.trim().split('\n').slice(-1)[0]
        //Get host from last line.
        let host = lastLine.match(/^(\S+)\s(.*)/).slice(1)[0]
        //Transform using subnet
        let arlocalGW = host.match(/.*\./) + '1'
        return arlocalGW
    }
    catch (err) {
        console.error(err)
    }
}

const storeWallet = (wallet, name) => {
    let jsonContent = JSON.stringify(wallet)
    let jsonWalletName = name + ".json"
    fs.writeFile(`${walletFolder}/${jsonWalletName}`, jsonContent, 'utf8', function (err) {
        if (err) {
            console.error("An error occurred while writing JSON wallet to a File.")
            return console.log(err)
        }
    })
}

const updateEnvFile = (matchString, filePath, replaceString) => {
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.error(err)
            return
        }
        let regex = new RegExp('^.*' + matchString + '.*$', 'm')
        let formatted = data.replace(regex, replaceString)
        fs.writeFile(filePath, formatted, 'utf8', function (err) {
            if (err) return console.log(err)
        })
    })
}

//Get Arlocal Host
const arlocalHost = await getArlocalHost()
//Generate ENV variable
const envArlocalGW = "ARWEAVE_GATEWAY=" + "'" + arlocalHost + "'"
//Update ENV file
updateEnvFile('ARWEAVE_GATEWAY=', envFilePath, envArlocalGW)

const arweave = new Arweave({
    host: arlocalHost,
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
    let jsonWalletPath = path.resolve(walletFolder + address + ".json")
    //Update ENV file
    updateEnvFile('ARLOCAL_WALLET=', envFilePath, 'ARLOCAL_WALLET=' + jsonWalletPath)
    console.log("Wallet file has been saved.")
    console.log("Wallet address:", address)
} else {
    console.error("Cannot reach Arlocal")
}

//TODO: Trigger to load this .env and documentation
//export $( grep -vE "^(#.*|\s*)$" bats-variables.env )
