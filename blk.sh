#!/bin/bash
# original script from blackcoin.nl (https://blackcoin.nl/scripts-for-using-blackcoin-from-the-command-line-interface/)
# adjusted to my likes yikes!
# also i added several functions like setpassword, changepassword, balance and addr
# DONE
# ----
# * added unlock
# * added setpassword
# * added changepassword
# * added balance
# * added addr
# * added alladdr
# * added possiblity to use rpcuser/rpcpass
# * added fallback for default cookie usage
# 
# FIXED
# -----
# 
# TODO
#-----
# * change user/pass cmdline option 
# * add cookie option
# * add datadir option

# ATTENTION, you need to adjust those values
# the directory the blackcoin-cli is located at
bin_home="/home/blk/bin/"
# the directory specified with --datadir, if not specified default is $HOME/.blackmore
data_dir="/home/blk/.blackmore/"
# username
rpc_user="EXAMPLE_USER"
# password for RPC access
rpc_password=""

usage="Usage: blk [ info | unlock | stake | latest | dust | past24 | setpassword | changepassword | acctbalance | acctaddr | addrbalance | alladdr ] \n \n
	info: Check basic info. \n
	unlock: Unlock the wallet for transfer; Passes password without storing it in memory. \n
	stake: Enables staking; Passes password without storing it in memory. \n
	latest: Compares latest block with the BlackcoinNL hosted block explorer. \n
	dust: Prunes dust from wallet. Dust is defined as less than .0001BLK. Requires jq. \n
	past24: Shows staking numbers from the past 24hrs. \n
	setpassword: Set encryption password if wallet is *UNENCRYPTED*.  \n
	changepassword: change wallet password. \n
	acctbalance: show balance of addresses derived from ACCOUNT name(using curl+cryptoid.info). \n
	addrbalance: show balance of addresses derived from ADDRESS name(using curl+cryptoid.info). \n
	alladdr: show all addr and balances \n
	acctaddr: show addresses of wallet ACCOUNT name\n"

if [ $rpc_user = 'EXAMPLE_USER' ];then
	echo 'No user given, using cookie.'
	blkc="$bin_home/blackmore-cli"
else
	echo 'Using rpc-user-authentication scheme'
	blkc="$bin_home/blackmore-cli -rpcuser=$rpc_user -rpcpassword=$rpc_password -datadir=$data_dir"

fi	


case $1 in

addrbalance ) 
	  if [ $# -ne 2 ]; then
		  echo 'No address give.'
		  echo 'Abort.'
		  exit
	  fi
	  	addr=$2
		bal=`curl "https://chainz.cryptoid.info/blk/api.dws?q=getbalance&a=$addr" 2>/dev/null`
		echo "Address					Balance"
		echo "$addr	$bal BLK"

	;;
acctbalance ) account='' 
	  myaddr=''
	  if [ $# -ne 2 ]; then
		  echo 'No accountname given, using default'
	  	  myaddr=`$blkc getaddressesbyaccount ""| jq .|grep \"B|sed -e 's/[ ",]//g'`
	  else
		  account=$2
	  	  myaddr=`$blkc getaddressesbyaccount "$account"| jq .|grep \"B|sed -e 's/[ ",]//g'`
	  fi
	  echo "Address					Balance"
	  for item in $myaddr; do 
		bal=`curl "https://chainz.cryptoid.info/blk/api.dws?q=getbalance&a=$item" 2>/dev/null`
		echo "$item	$bal BLK"
	  done
	;;

acctaddr )    account='' 
	  myaddr=''
	  if [ $# -ne 2 ]; then
		  echo 'No accountname given, using default'
	  	  myaddr=`$blkc getaddressesbyaccount ""| jq .|grep \"B|sed -e 's/[ ",]//g'`
	  else
		  account=$2
		  echo $account
	  	  myaddr=`$blkc getaddressesbyaccount "$account"| jq .|grep \"B|sed -e 's/[ ",]//g'`
	  fi
	  echo 'Address'
	  for i in `echo $myaddr`; do echo $i; done
	;;

alladdr ) $blkc listaddressgroupings
	;;
info )
	$blkc getwalletinfo | egrep "balance|staked_balance|txcount|unconfirmed_balance|immature_balance|total_balance";
	$blkc getnetworkinfo | egrep "subversion|connections";
	$blkc getinfo | egrep "blocks";
	$blkc getblockchaininfo | egrep "best";
	$blkc getstakinginfo | egrep "enabled|staking|netstakeweight|expectedtime";
;;	

setpassword )
	echo 'Set password for *UNENCRYPTED* wallet'
	read -s BLKPW
	$blkc encryptwallet $BLKPW
	BLKPW=null
;;

changepassword )
	echo 'Set new password, enter OLD password'
	read -s BLKPWOLD
	echo 'Set new password, enter NEW password'
	read -s BLKPWNEW
	$blkc walletpassphrasechange $BLKPWOLD $BLKPWNEW
	BLKPWOLD=null
	BLKPWNEW=null
;;

unlock )
	echo 'ATTENTION! Unlocking Wallet!'
	echo 'enter Blackcoin Password'
	read -s BLKPW
	$blkc walletpassphrase $BLKPW 99999999 false
	BLKPW=null
;;

stake )
	echo 'Change Wallet to STAKING ONLY'
	echo 'enter Blackcoin Password'
	read -s BLKPW
	$blkc walletpassphrase $BLKPW 99999999 true
	BLKPW=null
;;

latest )
	latest=$($blkc  getblockcount) && \
	    blacksight=$(curl -s https://node.blackcoin.io/insight-api/block-index/$latest? |  cut -d '"' -f4) && \
	    blackmore=$($blkc  getblockhash $latest) && \
	    diff -sy --label Local <(echo $blackmore) --label Explorer <(echo $blacksight)
;;

dust )
	IFS=$'\n';

	$blkc listtransactions "*" 99999 | jq -r '.[] | select(.category != "send") | select(.amount < .0001) | .txid' | uniq >txid.txt

	while read line; do
	        echo $line 
	        $blkc removeprunedfunds $(echo $line)
	done < "txid.txt"
;;

past24 )
	latest=$($blkc getblockcount)
	since=$(expr $latest - 1350)
	hash=$($blkc getblockhash $since)
	past24=$($blkc listsinceblock $hash | jq -r '.[] | .[] | select(.confirmations > 0) | select(.amount = 0) .confirmations' 2> /dev/null | wc -l)

	total=$($blkc getwalletinfo | jq -r ' .total_balance | round')
	per10k=$(echo "scale=2; $past24/($total/10000)" | bc -l)
	echo $past24 stakes over the past 24hrs...   "$per10k" per 10k BLK...
;;

*)
    echo -e $usage
;;	

esac
