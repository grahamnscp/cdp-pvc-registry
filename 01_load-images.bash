#!/bin/bash

source params.sh

# download manifest.json from website
curl -s -u $USERNAME:$PASSWORD -o ${MANIFEST_FILE} ${CLOUDERA_WEBSITE_PATH}/manifest.json


# Parse manifest and load associative arrays
COUNT=0
for FURL in `grep -Eo '"tar_url":.*?[^\\]",' $MANIFEST_FILE | sed 's/\"//g'|sed 's/\,//g'|awk '{print $2}'`
do
  COUNT=$(($COUNT+1))
  FILE_URLS[$COUNT]=$FURL
done
NUM_IMAGES=$COUNT

COUNT=0
for IPATH in `grep -Eo '"path":.*?[^\\]",' $MANIFEST_FILE | grep -v .tgz | sed 's/\"//g'|sed 's/\,//g'|awk '{print $2}'`
do
  COUNT=$(($COUNT+1))
  IMG_PATHS[$COUNT]=$IPATH
done

COUNT=0
for IVER in `grep -Eo '"version":.*?[^\\]",' $MANIFEST_FILE | sed -n '1!p' | sed 's/\"//g'|sed 's/\,//g'|awk '{print $2}'`
do
  COUNT=$(($COUNT+1))
  IMG_TAGS[$COUNT]=$IVER
done

# download image files, load into local docker daemon
mkdir -p images
for (( COUNT=1; COUNT<=$NUM_IMAGES; COUNT++ ))
do
  FILE_NAME=${FILE_URLS[$COUNT]}
  FULL_IMAGE_NAME=${CLOUDERA_REGISTRY_PATH}/${IMG_PATHS[$COUNT]}:${IMG_TAGS[$COUNT]}

  echo processing image file [$COUNT]: $FILE_NAME

  if [ ! -f ${FILE_NAME} ]
  then
    echo downloading image tar: ${FILE_NAME} ..
    curl -s -u $USERNAME:$PASSWORD -o ${FILE_NAME} ${CLOUDERA_WEBSITE_PATH}/${FILE_NAME}
  fi

  if [ ! -f ${FILE_NAME} ]; then echo "File not found!" 
  else
    # before loading file, check if image already exists
    if [[ "$(docker images -q ${FULL_IMAGE_NAME} 2> /dev/null)" == "" ]]
    then
      echo loading image file: `ls $FILE_NAME`
      docker load < ${FILE_NAME}
    else
      echo ${FULL_IMAGE_NAME} image already loaded
    fi
  fi
  echo "--------------------------------------------------------------------------------"
done

