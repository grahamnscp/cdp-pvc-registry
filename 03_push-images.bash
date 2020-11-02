#!/bin/bash

source params.sh

# push all tagged images in local daemon to remote registry
COUNT=0
for IMG in `docker images | grep $LOCAL_REGISTRY | sed 's/$LOCAL_REGISTRY\///' | awk '{printf "%s:%s\n",$1,$2}'`
do
  COUNT=$(($COUNT+1))
  IMG_PATH=`echo $IMG | awk -F ':' '{print $1}'`
  IMG_TAG=`echo $IMG | awk -F ':' '{print $2}'`

  echo [$COUNT] processing image: $LOCAL_REGISTRY/$IMG_PATH:$IMG_TAG

  # check if exists in remote registry before pushing
  if [ "$(curl --silent -i http://$LOCAL_REGISTRY/v2/$IMG_PATH/manifests/$IMG_TAG | grep "200 OK" 2> /dev/null)" ]
  then
    echo image already present in registry
  else
    echo pushing image ..
    docker push $IMG
  fi

  echo "--------------------------------------------------------------------------------"
done

