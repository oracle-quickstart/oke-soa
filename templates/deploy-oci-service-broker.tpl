## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

CHART_VERSION=1.5.2
# if editing the CHART_VERSION also make sure to edit the image tag in the osb-values.yaml to match the image version

helm install oci-service-broker https://github.com/oracle/oci-service-broker/releases/download/v$CHART_VERSION/oci-service-broker-$CHART_VERSION.tgz \
  --namespace oci-service-broker \
  --set image.repository=iad.ocir.io/ocisateam/oci-service-broker/oci-service-broker \
  --set image.tag=1.5.3 \
  --set ociCredentials.secretName="osb-credentials" \
  --set storage.etcd.servers='https://etcd-0.etcd-headless.oci-service-broker.svc.cluster.local:2379\,https://etcd-1.etcd-headless.oci-service-broker.svc.cluster.local:2379\,https://etcd-2.etcd-headless.oci-service-broker.svc.cluster.local:2379' \
  --set storage.etcd.tls.clientCertSecretName=etcd-client-tls-cert-osb \
  --set tls.secretName=osb-client-tls-cert 

while [[ $(kubectl get pods -l app=oci-service-broker -n oci-service-broker -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
    echo "waiting for oci-service-broker pod" && sleep 1; 
done
