## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

CHART_VERSION=10.19.5

helm repo add traefik https://helm.traefik.io/traefik

helm install traefik \
traefik/traefik \
--version 10.19.5 \
--namespace ${ingress_namespace} \
--set image.tag=2.6.6 \
--set ports.traefik.expose=true \
--set ports.web.exposedPort=30305 \
--set ports.web.nodePort=30305 \
--set ports.websecure.exposedPort=30443 \
--set ports.websecure.nodePort=30443 \
--set "kubernetes.namespaces={${ingress_namespace},${soa_namespace}}" \
--wait

echo "Traefik is installed and running"
