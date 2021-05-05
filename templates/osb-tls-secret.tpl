## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

pushd ./keys
mkdir -p osb
pushd osb

# generate a password for the certificate keystore
PASSWORD=$(openssl rand -base64 32)

# create a new cert
openssl req -newkey rsa:2048 -config ../osb.conf -nodes -keyout key.pem -x509 -days 3650 -out certificate.pem
# package the cert in PKCS12 keystore
openssl pkcs12 -inkey key.pem -in certificate.pem -export -out certificate.p12 -passout pass:$PASSWORD

# create the kubernetes secret for the OSB pod to use 
kubectl create secret generic osb-client-tls-cert --from-literal=keyStore.password=$PASSWORD --from-file=keyStore=certificate.p12 -n oci-service-broker

# encode the cert to base64
CA_BUNDLE=$(cat certificate.pem | base64)
popd
popd
# inject the caBundle parameter in the ClusterBinding template.
sed -e "s|SUBSTITUTE_CA_BUNDLE|$CA_BUNDLE|;" ./templates/oci-service-broker.ClusterServiceBroker.yaml.tpl > ./templates/oci-service-broker.ClusterServiceBroker.yaml