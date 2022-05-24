## Copyright (c) 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

imagePullSecrets: 
  - name: image-secret

oracledb:
  provision: false
  credentials:
    secretName: ${db_secret}
  url: ${jdbc_connection_url}

kubernetesVersion: ${k8s_version}

domain:
  domainName: ${soa_domain_name}
  type: ${soa_domain_type}
  credentials: 
    secretName: ${soa_domain_secret}
  rcuSchema:
    prefix: ${rcu_prefix}
    credentials:
      secretName: ${rcu_secret}
  storage:
    path: ${path}
    nfs:
      server: ${nfs_server_ip}
