# cdp-pvc-registry

## Details on setting up local secure docker registry
```
CERTSDIR=/root/certs
mkdir -p $CERTSDIR

```


## Generate a new Root CA
```
openssl genrsa -des3 -out $CERTSDIR/rootCA.key 4096
openssl req -x509 -new -nodes -key $CERTSDIR/rootCA.key -sha256 -days 1024 -out $CERTSDIR/rootCA.crt

```


## Generate a Server Cert Key
```
openssl genrsa -out $CERTSDIR/server.key 2048
openssl ecparam -genkey -name secp384r1 -out $CERTSDIR/server.key

```


## Generate a Certificate Signing Request for the Server and sign with the Root CA
```
openssl req -new -sha256 -key $CERTSDIR/server.key -subj "/C=UK/ST=London/O=Example, Co./CN=registry.example.com" \
            -out $CERTSDIR/server.csr
#openssl req -in $CERTSDIR/server.csr -noout -text

openssl x509 -req -in $CERTSDIR/server.csr -CA $CERTSDIR/rootCA.crt -CAkey $CERTSDIR/rootCA.key -CAcreateserial \
             -out $CERTSDIR/server.crt -days 3650 -sha256

```


## I'm on Centos 7 (/RHEL) so update OS level CA anchors (restart local docker daemon afterwards)
```
cp $CERTSDIR/RootCA.crt /etc/pki/ca-trust/source/anchors/my-rootCA.crt
update-ca-trust
systemctl restart docker

```


## Start up the 'secure' registry with the SSL certificate
```
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name secregistry \
  -v $CERTSDIR:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/server.key \
  registry:2.7.1

#  -p 5001:5001 \
#  -e REGISTRY_HTTP_DEBUG_ADDR=':5001' \

# quick test
openssl s_client -showcerts -connect localhost:5000 | grep hello
```


## test pushing and pulling
```
docker pull grahamh/hello-docker:latest
docker tag grahamh/hello-docker:latest registry.example.com:5000/grahamh/hello-docker:latest

docker rmi registry.example.com:5000/grahamh/hello-docker:latest
docker rmi grahamh/hello-docker:latest

docker run -it --rm registry.example.com:5000/grahamh/hello-docker:latest
Unable to find image 'registry.example.com:5000/grahamh/hello-docker:latest' locally
latest: Pulling from grahamh/hello-docker
5087e76690dc: Pull complete
Digest: sha256:4c31e9319f419b9f4427af3b3bb548ed166409009b880c6860c21652d21d05bc
Status: Downloaded newer image for registry.example.com:5000/grahamh/hello-docker:latest

                              ##         .
                        ## ## ##        ==
                     ## ## ## ## ##    ===
                 /"""""""""""""""""\___/ ===
            ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
                 \______ o           __/
                   \    \         __/
                    \____\_______/
 _           _    _                _            _
| |     ___ | |  | |    ___     __| | ___   ___| | _____ _ __
| |___ / _ \| |  | |   / _ \   / _  |/ _ \ / __| |/ / _ \ '__|
|  _  |  __/| |__| |__| (_) | | (_| | (_) | (__|   <  __/ |
|_| |_|\___/ \___|\___|\___/   \__,_|\___/ \___|_|\_\___|_|

```
