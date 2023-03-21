#!/bin/bash

sourceRepo=$1
sourceServer=$2
sourceUser=$3
sourcePassword=$4
artifactsFile=$sourceRepo/$sourceRepo-artifacts.txt


# ======== UPLOAD EVERYTHING =========
echo Uploading artifacts...
urls=($(cat $artifactsFile)) > /dev/null 2>&1
for asset in "${urls[@]}"; do
    pathToFile=${asset#*/*/*/*/*}
    echo $pathToFile
    curl -vks -u "$sourceUser:$sourcePassword" --upload-file $pathToFile $sourceServer/repository/$pathToFile >> /dev/null 2>&1
done