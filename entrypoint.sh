#!/bin/sh
# Check ENVs
if [ -z ${OVH_DOMAIN+x} ]; then echo "Variable OVH_DOMAIN is unset"; exit 1; fi
if [ -z ${OVH_USER+x} ]; then echo "Variable OVH_USER is unset"; exit 1; fi
if [ -z ${OVH_PASSWORD+x} ]; then echo "Variable OVH_PASSWORD is unset"; exit 1; fi

WAIT_TIME="${WAIT_TIME:-60}"

while true
do
	# Get the current registered IP
	nslookup -type=a $OVH_DOMAIN resolver1.opendns.com
	OLD_IP=$(nslookup -type=a $OVH_DOMAIN resolver1.opendns.com | awk -F': ' 'NR==6 { print $2 } ')
	echo "OLD_IP: $OLD_IP"

	# Get current external IP
	NEW_IP=$(wget -q -O - ipinfo.io/ip)
	echo "NEW_IP: $NEW_IP"

	if [[ $OLD_IP != $NEW_IP ]]; then
		echo "IP Change Detected. Update needed."
		CREDS=$(echo -n "$OVH_USER:$OVH_PASSWORD" | base64 -w0)
		wget -q --header "Authorization: Basic $CREDS" "https://www.ovh.com/nic/update?system=dyndns&hostname=$OVH_DOMAIN&myip=$NEW_IP&wildcard=OFF&backmx=NO&mx=NOCHG"
	else
		echo "No need to update the IP"
	fi
	sleep $WAIT_TIME
done
