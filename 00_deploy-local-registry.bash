#!/bin/bash

# Running a docker registry as a docker container
# you will need to add the registry name to the insecure registry list
# in the docker daemon config as this image does not have an SSL server
#
# /etc/docker/daemon.json:
#{
#  "storage-driver": "overlay2",
#  "storage-opts": ["overlay2.override_kernel_check=true"],
#  "log-driver": "journald",
#  "log-level": "info",
#  "log-opts": {
#    "tag":"{{.ImageName}}/{{.Name}}/{{.ID}}"
#  },
#  "insecure-registries":["registry.example.com:5000"]
#}
#
# and restart docker: sudo systemctl restart docker

docker run -d -p 5000:5000 --restart always --name registry registry:2.7.1

