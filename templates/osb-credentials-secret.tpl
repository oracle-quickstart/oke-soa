## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

if [[ ! $(kubectl get secret osb-credentials -n oci-service-broker) ]]; then
    kubectl create secret generic osb-credentials \
    -n oci-service-broker \
    --from-literal=tenancy=${tenancy_ocid} \
    --from-literal=user=${user_ocid} \
    --from-literal=fingerprint=${fingerprint} \
    --from-literal=region=${region} \
    --from-literal=passphrase="" \
    --from-file=privatekey=${private_key_path}
fi 

