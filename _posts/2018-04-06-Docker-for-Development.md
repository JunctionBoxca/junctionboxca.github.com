---
title:       Docker for Development
created_at:  2018-04-06 12:00:00 +00:00
layout:      default
published:   true
description:
  Containers as a concept seem here to stay but there’s a lot of smart cookies
  exploring “what is the best utility of it for daily development” in particular
  the reason for this post was “what is the best practise for using security
  credentials in a container”. This post is my naive attempt at cracking that
  nut with the hope of getting some healthy feedback.
keywords: docker
tags: docker
---

Containers as a concept seem here to stay but there’s a lot of smart cookies exploring “what is the best utility of it for daily development” in particular the reason for this post was “what is the best practise for using security credentials in a container”. This post is my naive attempt at cracking that nut with the hope of getting some healthy feedback. I have to attribute a good deal of the use of docker compose to this [Heroku post](https://devcenter.heroku.com/articles/local-development-with-docker-compose).

In my limited experience Docker feels like a double-edged sword. It’s easy to launch images but if you’re not familiar with a few key concepts you’ll find your disk full before the days done and the keys to your castle published to Docker Hub.

## What we’re baking

A docker environment with as much RAM and CPU as you’re willing to allocate that is easy(-ish) to manage.

**Goals**

- minimise storage usage.
- outline simple command line workflow.
- provide reasonable performance.
- minimise security risks.

**Non-Goals** ✝

- Windows/Linux setup. (although some principles are likely cross-cutting)
- forward OS X SSH agents see [docker/for-mac#483](https://github.com/docker/for-mac/issues/483).
- production deployments.
- CI builds.

✝ - I might address these in a future article.

## Ingredients

- Docker for Mac - Edge (better on your battery IME and more hipster than edgy).
- Selection of your finest crafted docker images.
- An editor to lovingly hand-craft your very own Dockerfile and Docker compose config.
- A little bit of patience.

## Recipe

1. In a mixing bowl pour in 1 packaged install of Docker for Mac (Edge).
2. In the Docker Tray icon click “Preferences” > “Advanced” and adjust the vCPU and RAM allocation to whatever you’re comfortable with (I would advise no more than 50% of your available resources).
3. Sift in a `Dockerfile` you can use for development such as;
```dockerfile
    FROM amazonlinux:latest
    RUN yum install -y \
        iputils \
        mysql57-devel \
        python27-devel \
        python27-pip
```
4. Gently mix in your `docker-compose.yaml` configuration such as;
```yaml
    version: '2'
    services:
      api:
        build: .
        ports: 
          - "5000:5000" # forward flask port to your desktop (replace as desired)
        depends_on:
          - db # this will cause db to be launched prior to launching this container
        volumes:
          - .:/app # this is an example of a bind mount
    
      db:
        image: "mysql:5.7"
        ports:
          - "3306:3306" # forward mysql port to your desktop
        environment:
          - MYSQL_ROOT_PASSWORD=secret
```
5. Place your dev image in the oven to bake with this command; `docker-compose build .`
6. Serve with your preference of garnish; `docker-compose run dev`

## Lordie, lordie why oh why?

You might want to do this for any of the following reasons;

- (Complexity/technology) (masochism/fetishism).
- Seeking a production “like” (as in library versions) environment.
- Tired of fighting with HomeBrew after updates to OS X.
- Simplified on-boarding.
- You ride a unicycle and Vagrant’s so last decade.
- “Coles Notes” datastore provisioning.

There are a few simple methods I’ve found to minimise filling your disk unnecessarily;

1. Name your containers at lauch to help you keep things organised.
2. Use docker compose as proposed above, which will name them for you.
3. Periodically spring clean unused layers and containers.

For keeping things secure it’s a little more nuanced and depends on your threat model but these should generally keep you safe on a local machine;

1. DO configure and use a private docker image repository to publish your images to.
2. DO NOT use `COPY` for anything remotely resembling credentials or secrets (IAM id/secret, ssh private key, github token, etc).
3. DO use bind mounts or run-time environment variables for credential access.
4. DO be selective of the containers you use.

## Phenomenal Cosmic Power!!

<small>Itty Bitty Livingspace</small>

To demonstrate how quickly you can fill your disk run these commands;
```bash
    df -h # display current disk utilisation
    docker run -it mysql:5.7 bash -c 'echo "Hello"'
    docker run -it amazonlinux:latest bash -c 'echo "Hello"'
    docker run -it ubuntu:trusty bash -c 'echo "Hello"'
    docker run -it ubuntu:latest bash -c 'echo "Hello"'
    df -h # display final disk utilisation
```
## Spring Cleaning

Now that you’ve filled your disk see if you can recover the space using these commands to list and clean layers, images, and containers:
```bash
    docker ps --all # list all containers
    docker images --all # list all images
    docker rmi $IMAGE_SHA # remove image,multiple SHAs permitted
    docker rm $CONTAINER_SHA # remove a containers image, multiple SHAs permitted
    docker system prune --all --force # burn it all down with gusto (use with caution)
```
