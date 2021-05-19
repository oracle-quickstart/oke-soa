## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

helm upgrade ${soa_domain_name} oracle/soa-suite -n ${soa_namespace} \
    --reuse-values \
    --set domain.enabled=false \
    --wait

helm delete ${soa_domain_name} -n ${soa_namespace}
