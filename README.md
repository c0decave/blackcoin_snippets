# blk.sh

original script from blackcoin.nl (https://blackcoin.nl/scripts-for-using-blackcoin-from-the-command-line-interface/)
adjusted to my likes yikes!
also i added several functions like setpassword, changepassword, balance and addr

# Configuration

ATTENTION, you need to adjust those values

* the directory the blackcoin-cli is located at
```
bin\_home="/home/blk/bin/"
```
* the directory specified with --datadir, if not specified default is $HOME/.blackmore
```
data_dir="/home/blk/.blackmore/"
```
* your username
```
rpc_user="YOURUSER"
```
* your password for RPC access
```
rpc_password="YOURPASSWORD"
```

# Usage

Commands available
```
Usage: blk [ info | unlock | stake | latest | dust | past24 | setpassword | changepassword | acctbalance | acctaddr | addrbalance | alladdr ]

 info: Check basic info.
 unlock: Unlock the wallet for transfer; Passes password without storing it in memory.
 stake: Enables staking; Passes password without storing it in memory.
 latest: Compares latest block with the BlackcoinNL hosted block explorer.
 dust: Prunes dust from wallet. Dust is defined as less than .0001BLK. Requires jq.
 past24: Shows staking numbers from the past 24hrs.
 setpassword: Set encryption password if wallet is *UNENCRYPTED*.
 changepassword: change wallet password.
 acctbalance: show balance of addresses derived from ACCOUNT name(using curl+cryptoid.info).
 addrbalance: show balance of addresses derived from ADDRESS name(using curl+cryptoid.info).
 alladdr: show all addr and balances
 acctaddr: show addresses of wallet ACCOUNT name

```
Example:
```
./blk.sh info
```

