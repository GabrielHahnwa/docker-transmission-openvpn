#!/bin/bash

# Usage:
# docker exec -it -w / **CONTAINER** bash -c "./etc/openvn/updateFreeVPN.sh"

DOMAIN=${OPENVPN_CONFIG%%-*}

OPENVPN_IP=$(curl -s https://freevpn.${DOMAIN}/accounts/ | grep IP |  sed s/"^.*IP\:.... "/""/g | sed s/"<.*"/""/g)
SERVER=${OPENVPN_IP%".freevpn.${DOMAIN}"}

DIR="/tmp/freevpn"
TARGET="/etc/openvpn/freevpn"
ZIP_FILE="/tmp/freevpn.zip"

# Use the OPENVPN_CONFIG env var to obtain running domain
URL=`curl -s https://freevpn."${DOMAIN}"/accounts/`
REGEX='<a +.*href="(https:.*\.zip)"'

# Create directory if not exits
if [[ ! -d "$DIR" ]]
then
        mkdir -p $DIR
fi

# Download FreeVPN Zip file
[[ $URL =~ $REGEX ]] && curl -s ${BASH_REMATCH[1]} -o ${ZIP_FILE}


# Unzip file
unzip -qo ${ZIP_FILE} -d $DIR


# Process content file
IFS=$'\n'
for i in $(find ${DIR} -iname "*${SERVER}*.ovpn")
do
	sed -i 's/route 0.0.0.0 0.0.0.0/redirect-gateway/' $i
	sed -i 's/auth-user-pass/auth-user-pass \/config\/openvpn-credentials.txt/' $i
	if [[ $i == *TCP* ]];
       	then
		sed -i 's/explicit-exit-notify//' $i
       	fi

	file=${i##*/}
	file=${file/FreeVPN./}
	
	file_name=$(basename $file)

	final_file=$DOMAIN-${file_name#*-}
	mv $i ${TARGET}/${final_file} > /dev/null 2>&1
done

# Delete temporary directory
rm -rf ${DIR}
