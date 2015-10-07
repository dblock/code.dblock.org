---
layout: post
title: "Docker-machine Hangs on Start: Testing TCP Connection"
date: 2015-10-07
tags: [docker, dusty]
comments: true
---
This was a stubborn one.

Was trying to use [Docker](https://www.docker.com) via [Dusty](http://dusty.gc.com) for the first time.

```
docker-machine --debug start dusty
```

This would hang with the following.

```
Testing TCP connection to: localhost:64623
Testing TCP connection to: localhost:64623
Testing TCP connection to: localhost:64623
...

```

No problems connecting to `localhost:64623` via `ssh localhost -p 64623`.

No issues navigating to http://localhost:64623. I would see a page with the SSH server version.

```
SSH-2.0-OpenSSH_6.4
```

The culprit was this entry in `/etc/hosts`, from some experimentation on blocking ads via a [hosts file](https://github.com/StevenBlack/hosts).

```
0 localhost
```

The fix was to properly define `localhost`.

```
127.0.0.1    localhost
::1 localhost
```

I opened [docker-machine#1946](https://github.com/docker/machine/issues/1946) to improve the error message here.
