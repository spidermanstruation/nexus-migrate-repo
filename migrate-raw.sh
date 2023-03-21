#!/bin/bash

SOURCE_URL=$2
SOURCE_LOGIN=
SOURCE_PASS=

DEST_URL=$3
DEST_LOGIN=
DEST_PASS=

REPO_TYPE=  # for example: raw, helm, etc.

if [ -n "$1" ]
then
    repo=$1
else
    echo "Usage: `basename $0` repo-name source-nexus dest-nexus"
fi

## GET SOURCE REPO INFO
echo Get $repo info from source
curl -X 'GET' \
  -u $SOURCE_LOGIN:$SOURCE_PASS \
  $SOURCE_URL/service/rest/v1/repositories/$REPO_TYPE/hosted/$repo \
  -H 'accept: application/json' > $repo.tmp.json

echo "Modify repo $repo json file"
sed -i 's/nexus.source.url/nexus.dest.url/' $repo.tmp.json ## Change url in JSON file
sed -i 's/"blobStoreName" : "<sourceBlobName>"/"blobStoreName" : "<destBlobName>"/' $repo.tmp.json ## Change blob in JSON file
echo "Download Assets"
./download-assets.sh $repo $SOURCE_URL $SOURCE_LOGIN $SOURCE_PASS

echo "Create new repository on target Nexus"
curl -X 'POST' -u $DEST_LOGIN:$DEST_PASS $DEST_URL/service/rest/v1/repositories/$REPO_TYPE/hosted \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d @$repo.tmp.json
echo "Updload Assets"
./upload-assets.sh $repo $DEST_URL $DEST_LOGIN $DEST_PASS
rm $repo.tmp.json

echo 
echo Done!