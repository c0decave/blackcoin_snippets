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
	info: Check basic info. \n
	stake: Enables staking; Passes password without storing it in memory. \n
	latest: Compares latest block with the BlackcoinNL hosted block explorer. \n
	dust: Prunes dust from wallet. Dust is defined as less than .0001BLK. Requires jq. \n
	past24: Shows staking numbers from the past 24hrs. \n
	setpassword: Set encryption password if wallet is *UNENCRYPTED*.  \n
	changepassword: change wallet password. \n
	balance: show balance of addresses (using curl). \n
	alladdr: show all addr and balances \n
	addr: show addresses of default wallet \n"
```
Example:
```
blk.sh info
```

