## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

mkdir -p $HOME/.kube/ 
oci ce cluster create-kubeconfig --cluster-id ${cluster_id} --file $HOME/.kube/config --region ${region} --token-version 2.0.0
