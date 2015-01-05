---
layout: post
title: "Installing a Specific Version of NodeJS, NPM and CoffeeScript"
redirect_from: "/installing-a-specific-version-of-nodejs-npm-and-coffeescript"
date: 2011-08-31 18:41:32
tags: [npm, nodejs, coffeescript, linux]
comments: true
---
The latest version of Node was segfaulting on my Linode. Here’s how to install a specific version.

I want Node 0.5.0, the latest NPM and CoffeeScript 1.0.1.

#### NodeJS 0.5.0 From a Tag


```
git clone https://github.com/joyent/node.git
cd node
git checkout "v0.5.0"
export JOBS=2 # optional, sets number of parallel commands.
./configure
make
make install
```

#### Latest NPM

```
curl http://npmjs.org/install.sh | sh
```

#### CoffeeScript 1.0.1

```
npm config set registry http://registry.npmjs.org
npm install -g coffee-script@1.0.1
```
