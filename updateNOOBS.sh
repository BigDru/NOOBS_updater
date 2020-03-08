#!/bin/bash
red='\033[1;31m'
def='\033[0m'

url="http://downloads.raspberrypi.org/NOOBS/images/"
#NOOBS_path is the path to the local archive of NOOBS images
#when dereferenced, it is surrounded by quotes to ensure the spaces aren't misinterpreted
NOOBS_path="/mnt/Repository of Knowledge/private/pi/"
printf "$current"

printf "\nFinding latest NOOBS image via Curl:\n\n"
latestPath=$(curl --max-time 4 --retry 999 --retry-delay 1 "$url" | sed -n 's/.*href="\([^"]*\).*/\1/p' | grep NOOBS-20 | tail -n 1)
#latestPath="NOOBS-2017-09-08/"

printf "\nLatest path: $url$latestPath\nFinding Zip:\n\n"
latest=$(curl --max-time 4 --retry 999 --retry-delay 1 "$url""$latestPath" | sed -n 's/.*href="\([^"]*\).*/\1/p' | grep zip | head -n 1)
#latest="NOOBS_v2_4_4.zip"

printf "\nFound: ${red}$latest${def}\n"
current=$(ls "$NOOBS_path" | grep zip)
count=$(ls "$NOOBS_path" | grep zip |wc -l)

#For future reference, note spacing:
if [[ $count == 0 ]]
then
	current="None"
elif [[ $count > 1 ]]
then
	current=$(echo "$current" | grep NOOBS | tail -n 1)
fi

printf "Current version: ${red}$current${def}\n\n"


if [[ "$current" != "$latest" ]]
then
	printf "Cleaning junk files in local archive\n"
	rm -rv "$NOOBS_path"
	printf "\n\nDownloading latest NOOBS image\nwget -cv -P --timeout=120 $NOOBS_path $url$latestPath$latest:\n\n"

	wget -cv --timeout=120 -P "$NOOBS_path" "$url""$latestPath""$latest"
elif [[ $count > 1 ]]
then
	printf "Latest NOOBS image already downloaded\n"
	printf "Cleaning junk files in local archive:\n\n"
	echo $(rm -rv !("$NOOBS_path""$latest"))
else
	printf "Latest NOOBS image already downloaded\n"
	#todo - verify hash and if not correct, redownload
fi
