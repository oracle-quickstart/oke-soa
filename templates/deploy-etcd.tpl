## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

helm repo add bitnami https://charts.bitnami.com/bitnami

CHART_VERSION=5.4.2

# check that the nodes are ready, and we have 3, or PVCs may fail to provision

while [[ $(for i in $(kubectl get nodes -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}'); do if [[ "$i" == "True" ]]; then echo $i; fi; done | wc -l | tr -d " ") -lt 3 ]]; do
    echo "waiting for at least 3 nodes to be ready..." && sleep 1;
done

helm install etcd bitnami/etcd --version $CHART_VERSION --namespace oci-service-broker \
    --set statefulset.replicaCount=3 \
    --set auth.rbac.enabled=false \
    --set auth.client.secureTransport=true \
    --set auth.client.enableAuthentication=true \
    --set auth.client.existingSecret=etcd-peer-tls-cert \
    --set auth.client.certFilename=tls.crt \
    --set auth.client.certKeyFilename=tls.key \
    --set auth.peer.secureTransport=true \
    --set auth.peer.enableAuthentication=true \
    --set auth.peer.existingSecret=etcd-peer-tls-cert \
    --set auth.peer.certFilename=tls.crt \
    --set auth.peer.certKeyFilename=tls.key \
    --set podAntiAffinityPreset=hard \
    --set metrics.enabled=true

while [[ $(kubectl get pod etcd-0 -n oci-service-broker -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
    echo "waiting for pod etcd-0" && sleep 1; 
done
while [[ $(kubectl get pod etcd-1 -n oci-service-broker -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
    echo "waiting for pod etcd-1" && sleep 1; 
done
while [[ $(kubectl get pod etcd-2 -n oci-service-broker -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
    echo "waiting for pod etcd-2" && sleep 1; 
done

echo "etcd is installed and running"
