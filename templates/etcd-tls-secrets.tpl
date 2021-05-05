## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

cd keys
mkdir -p client peer
# create CA if it doesn't exist
if [[ ! -f ca.pem ]]; then
    # gen Root CA key
    openssl genrsa -out ca-key.pem 2048
    # gen Root CA Certificate
    openssl req -x509 -config ca.conf -new -nodes -key ca-key.pem -days 3650 -out ca.pem
fi

## gen peer certificate and key
# gen peer key
openssl genrsa -out peer-key.pem 2048
# gen peer csr
openssl req -new -key peer-key.pem -out peer.csr -config peer.conf
# gen peer cert by signing csr with CA
openssl x509 -req -in peer.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out peer.pem -days 3650 -extensions v3_req -extfile peer.conf
# copy files over to the peer folder with the proper names for the secret
cp ca.pem peer/ca.crt
cp peer.pem peer/tls.crt
cp peer-key.pem peer/tls.key

## gen client certificate and key for etcd
# gen client key
openssl genrsa -out client-key.pem 2048
# gen client csr
openssl req -new -key client-key.pem -out client.csr -config client.conf
# gen client cert by signing csr with CA
openssl x509 -req -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out client.pem -days 3650 -extensions v3_req -extfile client.conf
# copy files over to the peer folder with the proper names for the secret
cp ca.pem client/ca.crt
cp client.pem client/tls.crt
cp client-key.pem client/tls.key

# convert cert and key for OSB
openssl pkcs8 -topk8 -nocrypt -in client-key.pem -out client/etcd-client.key
cp ca.pem client/etcd-client-ca.crt
cp client.pem client/etcd-client.crt

pushd peer
kubectl create secret generic etcd-peer-tls-cert -n oci-service-broker \
--from-file=ca.crt \
--from-file=tls.key \
--from-file=tls.crt
popd

pushd client
# cert for etcd
kubectl create secret generic etcd-client-tls-cert -n oci-service-broker \
--from-file=ca.crt \
--from-file=tls.key \
--from-file=tls.crt

# modified cert for OSB
kubectl create secret generic etcd-client-tls-cert-osb  -n oci-service-broker \
--from-file=etcd-client-ca.crt \
--from-file=etcd-client.key \
--from-file=etcd-client.crt
popd

while [[ "$(kubectl get secrets -n oci-service-broker | grep "etcd-client-tls-cert" | wc -l | tr -d ' ')" == "0" ]]; do
    echo "waiting for etcd-client-tls-cert secret to be created" && sleep 1
done
while [[ "$(kubectl get secrets -n oci-service-broker | grep "etcd-peer-tls-cert" | wc -l | tr -d ' ')" == "0" ]]; do
    echo "waiting for etcd-peer-tls-cert secret to be created" && sleep 1
done
while [[ "$(kubectl get secrets -n oci-service-broker | grep "etcd-client-tls-cert-osb" | wc -l | tr -d ' ')" == "0" ]]; do
    echo "waiting for etcd-client-tls-cert-osb secret to be created" && sleep 1
done