## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

if [[ ! $(kubectl get secret ${name} -n ${namespace}) ]]; then
    kubectl create secret generic ${name} -n ${namespace} \
        --from-literal=username=${username} \
        --from-literal=password='${password}'
fi