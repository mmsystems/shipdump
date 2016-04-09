#!/bin/bash
#
#  Search in shodan.io
#  Given a query, get the ip addresses
#
###########################################
#  @mark__os  ##  http://hackaffeine.com  #
###########################################
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#

#Shodan user credentials (inside single quotes!)
#YOU MUST CHANGE THIS WITH YOUR OWN USER AND PASSWORD!
USER='YourShodanUSER'
PASSWORD='YourShodanPASSWORD'

#Forge Post Data to send with wget
POST_DATA="username=$USER&password=$PASSWORD"

#Color definitions
red="\033[0;31m"
redC="\033[1;31m"
green="\033[0;32m"
greenC="\033[1;32m"
yellow="\033[1;33m"
gray="\033[1;30m"
brown="\033[0;33m"
white="\033[1;37m"
blueC="\033[1;34m"
reverse="\E[7m"
basecolor="\E[0m"

help(){
	echo -e ""$greenC"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"$basecolor""
	echo -e ""$greenC"┃"$basecolor" "$white"SHODAN IP DUMPER - http://hackaffeine.com "$greenC"┃"$basecolor""
	echo -e ""$greenC"┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"$basecolor""
	echo -e "\n "$white"- USAGE:"$basecolor""
	echo -e "\n\t $0 'seach query'"
	echo -e "\n "$white"- Examples:"$basecolor""
	echo -e "\n\t $0 'port:8080 country:es admin/admin'"
	echo -e "\t $0 'city:Madrid port:21 vsftpd'"
	echo -e "\t $0 'port:23 UNITED STATES GOVERNMENT COMPUTER'\n"
	exit 1
}

#Do login and save cookies
login() {
	wget -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/37.0.2062.120 Chrome/37.0.2062.120 Safari/537.36' \
		--secure-protocol=auto \
		--save-cookies /tmp/save.txt \
		--keep-session-cookies \
		--post-data $POST_DATA \
		-q \
		-O /tmp/login \
		https://account.shodan.io/login
	if [ -z "$(grep 'Show API Key' /tmp/login)" ]
		then
			echo -e "["$redC"-"$basecolor"] Login ERROR"
			echo -e "\n"$redC" * "$white"Edit the script "$redC"$0"$basecolor""$white" with a correct USER and PASSWORD for shodan.io"$basecolor"\n"
			exit 1
		else
			echo -e "["$greenC"+"$basecolor"] Login OK"
	fi
}

#Search query
search(){
	wget -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/37.0.2062.120 Chrome/37.0.2062.120 Safari/537.36' \
		--load-cookies /tmp/save.txt \
		-q \
		-O /tmp/result_shodan_download \
		https://www.shodan.io/search?query=$QUERY\&page=$PAGE

	IPS=$(strings /tmp/result_shodan_download | grep '/host/' | awk -F\" '{ print $4 }' | awk -F/ '{ print $3 }' | uniq)

	#When no find more IP's, try six times. If no results, exit script
	if [ "$IPS" == "" ]
		then
			let ATTEMPT=$ATTEMPT+1
			if [ "$ATTEMPT" == "6" ]
				then
					exit 0
				else
					search
			fi
	fi
}

#Show results stored in IPS var
show(){
	for i in $(echo $IPS)
			do
				echo "$i"
				let TOTAL_IP_CONT=$TOTAL_IP_CONT+1
	done
}

####################
### MAIN PROGRAM ###
####################

if [ ! -z "$1" ]
	then
		QUERY=$(echo "$@")
	else
		help
fi
#Format query to GET call (substitute spaces with + symbol)
QUERY=$(echo $QUERY | sed 's/ /+/g')

#If exist previous downloaded info, remove it
if [ -f /tmp/save.txt ]
	then
		rm -rf /tmp/save.txt
elif [ -f /tmp/login ]
	then
		rm -rf /tmp/login
fi

#Show Loading on screen
echo -e "["$yellow"i"$basecolor"] Loading . . ."

#Execute login in shodan.io, search query and show IP's as result
echo -e "["$yellow"i"$basecolor"] Do login"
login

#First search to get total results number
echo -e "["$yellow"i"$basecolor"] Searching"
search

#Extract total results and save it in NUM_RESULTS
NUM_RESULTS=$(awk '/Total results/ { print $4 }' /tmp/result_shodan_download | awk -F\< '{ print $1 }' | sed 's/,//g')
echo -e ""$reverse""$white"  TOTAL RESULTS: "$basecolor""$greenC"  $NUM_RESULTS  "$basecolor""

#IP results counter
TOTAL_IP_CONT=0

#Results page of shodan to start downloading
PAGE=1

#Main loop to download all results
while [ "$TOTAL_IP_CONT" -le "$NUM_RESULTS" ]
	do
		ATTEMPT=1
		search
		show
		let PAGE=$PAGE+1
done

