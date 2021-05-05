#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
apiVersion: servicecatalog.k8s.io/v1beta1
kind: ClusterServiceBroker
metadata:
  name: oci-service-broker
spec:
  # Make sure to replace <NAMESPACE_OF_OCI_SERVICE_BROKER> with suitable namespace if OCI Service Broker and Service Catalog are installed in different namespaces.
  # Please remove <NAMESPACE_OF_OCI_SERVICE_BROKER> from below URL attribute If both OCI Service Broker and Service Catalog are installed in the same namespace.
  url: https://oci-service-broker.oci-service-broker.svc.cluster.local:8080
  caBundle: SUBSTITUTE_CA_BUNDLE
