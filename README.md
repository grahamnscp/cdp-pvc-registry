# cdp-pvc-registry
Some scripts to populate a local docker registry with CDP-PVC images

## Populate the details in the params.sh file that is used by the scripts
```
# params.sh
#
# Authentication details from Cloudera CDP license
USERNAME=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
PASSWORD=xxxxxxxxxxxx

CLOUDERA_WEBSITE_PATH=https://archive.cloudera.com/p/cdp-pvc/1.0.2-b2/
MANIFEST_FILE=manifest.json

CLOUDERA_REGISTRY_PATH=container.repository.cloudera.com/cdp-private

LOCAL_REGISTRY=registry.example.com:5000
LOCAL_REGISTRY_DIR=cdp-private
LOCAL_REGISTRY_PATH=$LOCAL_REGISTRY/$LOCAL_REGISTRY_DIR
LOCAL_REGISTRY_PROTO=https
```


## On-prem Docker registry
If you need to run a simple docker registry use the docker image, either inscure or secure

### Inescure Registry:
Script, 00_deploy-local-registry.bash spins up an insecure docker registry

### Secure Docker RegistryL
Follow steps in SECURE_REGISTRY.md to spin up a secure registry.  

note: the params.sh:LOCAL_REGISTRY_PROTO=https needs to reflect the registry protocol.


## Download docker images

Script 01_load-images.bash downloads the docker images for CDP PVC from the archive website, not that you need a license key to do this, there is a 60 day trial option.  Update the version as appropriate, this example used 1.0.2-b2 but things are moving very fast.

The script creates a relative subdirectory ./images/ and downloads the images there if a file of the same name doesn't already exist.  If you have a failed download then remove the partially downloaded file and rerun the script.  CDP PVC image tars are around 23GB on disk.

The key file that is used for the content to download is based on the manifest.json file which is curled from $CLOUDERA_WEBSITE_PATH/$MANIFEST_FILE
```
$ source params.sh
$ curl -u $USERNAME:$PASSWORD -o manifest.json ${CLOUDERA_WEBSITE_PATH}/${MANIFEST_FILE}
```

Once an image tar is downloaded it is imported into the local docker daemon if not already there.

This script can be rerun multiple times if necessary to process all the images.

note: I don't hash check the images, you may want to add that if using in production


## Tag the images for local registry
using script 02_tag-images.bash

note: checks source image name present and if it's already tagged before tagging


## Push images to local registry
using script 03_push-images.bash

note: checks if tagged image is already present in the registry before pushing

