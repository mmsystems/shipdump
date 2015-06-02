# sipdump

*******************************************
 SHODAN IP DUMPER - http://hackaffeine.com
******************************************* 

 - FIRST:

	Change USER and PASSWORD variables inside script to your own!
	##Shodan user credentials (inside single quotes!)
	##YOU MUST CHANGE THIS WITH YOUR OWN USER AND PASSWORD!
	USER='YourShodanUSER'
	PASSWORD='YourShodanPASSWORD'

 - USAGE:

         ./sipdump.sh 'seach query'

 - Examples:

         ./sipdump.sh 'port:8080 country:es admin/admin'
         ./sipdump.sh 'city:Madrid port:21 vsftpd'
         ./sipdump.sh 'port:23 UNITED STATES GOVERNMENT COMPUTER'
