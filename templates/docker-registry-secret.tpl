## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

if [[ ! $(kubectl get secret image-secret -n ${namespace}) ]]; then
    kubectl create secret docker-registry image-secret -n ${namespace} --docker-server=container-registry.oracle.com --docker-username='${email}' --docker-password='${password}' --docker-email='${email}'
fi