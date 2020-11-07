---
title:       The Docker Hubpocalypse
created_at:  2020-11-06 12:00:00 +00:00
layout:      default
published:   true
description:
  Docker is understandably changing it's terms of service for pull requests by
  anonymous accounts. This will have a big impact on a number of companies but
  there are a few different approaches you can take to minimise impact on your
  Kubernetes clusters.
keywords: docker kubernetes
tags: docker kubernetes
---

As of [Nov 2nd, 2020](https://www.docker.com/increase-rate-limits?utm_source=docker&utm_medium=web%20referral&utm_campaign=pull%20limits%20hub%20home%20page&utm_budget=) Docker Hub has begun
 rate limiting the number of anonymous image pull requests from their registry.
 This has potentially broad impact particularly for large Kubernetes clusters
that depend on public images. Over a period of time the limits will gradually be
 reduced to:

* 100 container image requests per six hours for anonymous usage.
* 200 container image requests per six hours for free Docker accounts.
* Unlimited container pull requests for Pro and Team accounts.

These limits are applied per IP address. How much impact this will have on your
 cluster will depend on a variety of factors such as:

* Does each node use public IP's to pull images or are they [NATed](https://en.wikipedia.org/wiki/Network_address_translation)?
* How often do the public images upstream change?
* Do you use an auto-scaler with frequent resizing?
* How often do pods move between hosts in your cluster?

By far the biggest impact will be Private IP clusters making requests via NAT. For
fixed size clusters the impact is likely to be low. A common configuration is
 `imagePull: Always` it is a common misconception that this always pulls the Docker
image. In reality it checks the SHA and only pulls the image when it differs.
Another consideration is that the most common elements consumed from public
repositories are infrastructure components like service meshes, egresses, log 
forwarders, and APM agents such as Instana. Relative to customer applications that
maybe deployed many times a day these often have longer release cycles meaning in
practise your clusters might not be heavily impacted by this change in service.

## What can you do?

There are a few different options you can consider to minimise your exposure:

1. Use image pull secrets.
1. Use Service Accounts.
1. Use a caching proxy.
1. Use a mirror.

## Image Pull Secrets

### Benefits

* Unlimited pull requests with a Pro/Team account.
* Simple and familiar approach for anyone using private repositories.

### Tradeoffs

* Requires pull secrets per namespace.
* Requires updating workloads.
* Potentially needs an Admission controller to auto-inject `imagePullSecret`.

### How To

See the Kubernetes official documentation on [creating](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)
 image pull secrets and [associating](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-pod-that-uses-your-secret)
 it with a workload.

## Service Account

### Benefits

* Many infrastructure components will have Service Accounts (SA) attached.

### Drawbacks

* Lesser know approach to associating pull secrets to a pod.
* Potentially needs an Admission controller to auto-inject the SA.

### How To

See the Kubernetes documentation on [adding secrets](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account)
to a Service Account.

## Caching Proxy

### Benefits

* Reduces total external bandwidth/latency for commonly used images.

### Tradeoffs

* Requires hooking into the docker configuration.
* If the accounts are unauthenticated still possible to hit rate-limit if consuming
 a high number of images and versions.
* Non-trival to configure with PaaS solutions such as GKE, AKS, and EKS.
* Additional infrastructe to manage and monitor.

### How To

See the Docker documentation on configuring a [pull through cache](https://docs.docker.com/registry/recipes/mirror/).
The key components to be aware of are configuring a proxy and docker.json:

1. Create a proxy: 
    ```
    docker run -d -p 6000:5000 \
    -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
    --restart always \
    --name registry registry:2
    ```
1. Update [docker.json](https://github.com/nfisher/k8smulti/blob/master/provision.sh#L47-L48)

## Mirror

### Benefits

* Independence from upstream maintainers.
* Potential to integrate Docker security scanners.

### Tradeoffs

* Additional overhead for keeping images up to date.
* Requires overriding image name for any related workloads.

### How

1. Docker pull.
1. Docker push.
1. Update image references for workloads.


## Conclusions

Of the above it's hard to be persprective of any single solution. You may choose
to mix and match the above as appropriate for your IT organisation.