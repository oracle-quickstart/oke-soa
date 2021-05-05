## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

if [[ ! $(kubectl get secret ocir-secret -n default) ]]; then
    kubectl create secret docker-registry ocir-secret -n default --docker-server=${region}.ocir.io --docker-username='${ocir_username}' --docker-password='${ocir_token}' --docker-email='jdoe@acme.com'
fi