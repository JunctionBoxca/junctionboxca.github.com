---
title:      GKE Multicluster
created_at: 2017-03-18 12:00:00 +00:00
layout:     default
published: true
description: I like to minimise my dependencies. Sadly the java.util.logging library is rather sparse on documentation when it comes to Uberjars. Read on for how I tamed this particular beast (more of a rabbit than a big cat).
keywords: java, logging
---

Start your clusters... multi-zone that is.

\`\`\`
export NAME=micro-cluster
gcloud container clusters create ${NAME} \\
--zone=us-central1-a \\
--additional-zones=us-central1-b,us-central1-c \\
--num-nodes=1 \\
--machine-type=f1-micro \\
--scopes=default,bigquery \\
--node-labels=env=prod
\`\`\`

Connect to GKE...

\`\`\`
gcloud config set compute/zone us-central1-a
gcloud config set container/cluster ${NAME}
gcloud container clusters get-credentials ${NAME}
gcloud auth application-default login
\`\`\`

Check if k8s is running

\`\`\`
kubectl
\`\`\`

Deploy an app:

\`\`\`

\`\`\`

Deploy HTTPS LB:

\`\`\`
export HCHK=app-check
export SVC=nginx-lb
gcloud compute http-health-checks create ${HCHK}
gcloud compute backend-services create ${SVC} \\
--protocol HTTP \\
--http-health-checks ${HCHK} \\
--timeout 5m \\
--region us-central1
\`\`\`

- https://cloud.google.com/container-engine/docs/clusters/operations
- https://cloud.google.com/compute/docs/load-balancing/tcp-ssl/
