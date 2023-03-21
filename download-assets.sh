#!/bin/bash

sourceRepo=$1
sourceServer=$2
sourceUser=$3
sourcePassword=$4

mkdir -p $sourceRepo
logfile=$sourceRepo/$sourceRepo-backup.log
outputFile=$sourceRepo/$sourceRepo-artifacts.txt
curFolder=$(pwd)
[ -e $outputFile ] && rm $outputFile




# ======== GET DOWNLOAD URLs =========
url=$sourceServer"/service/rest/v1/assets?repository="$sourceRepo
contToken="initial"
while [ ! -z "$contToken" ]; do
    if [ "$contToken" != "initial" ]; then
        url=$sourceServer"/service/rest/v1/assets?continuationToken="$contToken"&repository="$sourceRepo
    fi
    echo Processing repository token: $contToken | tee -a $logfile
    response=`curl -ksSL -u "$sourceUser:$sourcePassword" -X GET --header 'Accept: application/json' "$url"`
    readarray -t artifacts < <( jq  '[.items[].downloadUrl]' <<< "$response" )
    printf "%s\n" "${artifacts[@]}" > artifacts.temp
    sed 's/\"//g' artifacts.temp > artifacts1.temp
    sed 's/,//g' artifacts1.temp > artifacts2.temp
    sed 's/[][]//g' artifacts2.temp > artifacts3.temp
    cat artifacts3.temp >> $outputFile
    contToken=( $(echo $response | sed -n 's|.*"continuationToken" : "\([^"]*\)".*|\1|p') )
    rm artifacts* > /dev/null 2>&1
done


# ======== DOWNLOAD EVERYTHING =========
    echo Downloading artifacts...
    urls=($(cat $outputFile)) > /dev/null 2>&1
    for url in "${urls[@]}"; do
        path=${url#*/*/*/*/*}
        dir=${path%/*}
        mkdir -p  $dir
        cd $dir
        curl -vks -u "$sourceUser:$sourcePassword" -D response.header -X GET "$url" -O  >> /dev/null 2>&1
        responseCode=`cat response.header | sed -n '1p' | cut -d' ' -f2`
        if [ "$responseCode" == "200" ]; then
            echo Successfully downloaded artifact: $url
        else
            echo ERROR: Failed to download artifact: $url  with error code: $responseCode
        fi
        rm response.header > /dev/null 2>&1
        cd $curFolder
    done