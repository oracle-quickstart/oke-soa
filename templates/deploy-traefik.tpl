## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

CHART_VERSION=2.2.8

helm repo add traefik https://helm.traefik.io/traefik

helm install traefik \
traefik/traefik \
--namespace ${ingress_namespace} \
--set image.tag=2.2.8 \
--set ports.traefik.expose=true \
--set ports.web.exposedPort=30305 \
--set ports.web.nodePort=30305 \
--set ports.websecure.exposedPort=30443 \
--set ports.websecure.nodePort=30443 \
--set "kubernetes.namespaces={${ingress_namespace},${soa_namespace}}" \
--wait

echo "Traefik is installed and running"
