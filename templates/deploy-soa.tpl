## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

helm repo add oracle https://oracle.github.io/helm-charts --force-update

helm install ${soa_domain_name} oracle/soa-suite \
    -f fromtf.auto.yaml \
    --namespace ${soa_namespace} \
    --version 0.2.0 \
    --wait  \
    --timeout 600s || exit 1

echo "SOA Domain is installed, please wait for all pods to be READY"
