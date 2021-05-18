#!/bin/bash
# original script from blackcoin.nl (https://blackcoin.nl/scripts-for-using-blackcoin-from-the-command-line-interface/)
# adjusted to my likes yikes!

# ATTENTION, you need to adjust those values
# the directory the blackcoin-cli is located at
bin_home="/home/blk/bin/"
# the directory specified with --datadir, if not specified default is $HOME/.blackmore
data_dir="/home/blk/.blackmore/"
# username
rpc_user="YOURUSER"
# password for RPC access
rpc_password="YOURPASSWORD"

usage="Usage: blk [ info | stake | latest | dust | past24 | setpassword | changepassword | balance | addr | alladdr ] \n \n
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

blkc="$bin_home/blackmore-cli -rpcuser=$rpc_user -rpcpassword=$rpc_password -datadir=$data_dir"

case $1 in

balance ) account='' 
	  myaddr=''
	  if [ $# -ne 2 ]; then
		  echo 'No accountname given, using default'
	  	  myaddr=`$blkc getaddressesbyaccount ""| jq .|grep \"B|sed -e 's/[ ",]//g'`
	  else
		  account=$2
	  	  myaddr=`$blkc getaddressesbyaccount $account| jq .|grep \"B|sed -e 's/[ ",]//g'`
	  fi
	  for item in $myaddr; do 
		bal=`curl "https://chainz.cryptoid.info/ric/api.dws?q=getbalance&&a=$item" 2>/dev/null`
		echo "$item: $bal"
	  done
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

stake )
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
