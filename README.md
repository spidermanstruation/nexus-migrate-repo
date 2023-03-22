# Migrating Nexus Repository

Scripts for migrating hosted repository between Nexus instances

## How to use

Open and modify [migrate-repo.sh](migrate-repo.sh)

Fill variables with appropriate values:
- `SOURCE_LOGIN` login of source Nexus
- `SOURCE_PASS` password of source Nexus
- `DEST_LOGIN` login of destination Nexus
- `DEST_PASS` password of destination Nexus
- `REPO_TYPE` repository type (raw, help, etc.)

Modify `sed` section 
```shel
    sed -i 's/"blobStoreName" : "<sourceBlobName>"/"blobStoreName" : "<destBlobName>"/' $repo.tmp.json ## Change blob in JSON file
```
Set permissions to run script
```shel
    chmod +x migrate-repo.sh download-assets.sh upload-assets.sh
```

And run the script
```shel
    ./migrate-repo.sh repo-name source-nexus dest-nexus
```