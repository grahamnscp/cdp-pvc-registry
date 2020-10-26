#!/bin/bash

source params.sh


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


# tag images for local repository
for (( COUNT=1; COUNT<=$NUM_IMAGES; COUNT++ ))
do
  IMAGE_NAME=${IMG_PATHS[$COUNT]}:${IMG_TAGS[$COUNT]}

  if [[ "$(docker images -q ${CLOUDERA_REGISTRY_PATH}/${IMAGE_NAME} 2> /dev/null)" == "" ]]
  then
    echo ${CLOUDERA_REGISTRY_PATH}/${IMAGE_NAME} not present!
  else
    if [[ "$(docker images -q ${LOCAL_REGISTRY_PATH}/${IMAGE_NAME} 2> /dev/null)" == "" ]]
    then
      echo [$COUNT] tagging: docker tag ${CLOUDERA_REGISTRY_PATH}/${IMAGE_NAME} ${LOCAL_REGISTRY_PATH}/${IMAGE_NAME}
      docker tag ${CLOUDERA_REGISTRY_PATH}/${IMAGE_NAME} ${LOCAL_REGISTRY_PATH}/${IMAGE_NAME}
    else
      echo ${LOCAL_REGISTRY_PATH}/${IMAGE_NAME} image already tagged
    fi
  fi

  echo "--------------------------------------------------------------------------------"
done
