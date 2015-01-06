---
layout: post
title: "Error: No such module on process.binding"
redirect_from: "/error-no-such-module-on-processbinding/"
date: 2013-10-03 21:52:01
tags: [nodejs, javascript]
comments: true
---

```
$ coffee app.coffee

/Users/dblock/.nvm/v0.10.17/lib/node_modules/coffee-script/lib/command.js:15
   return process.binding('stdio').writeError(line + '\n');
                  ^
Error: No such module
   at printWarn (/Users/dblock/.nvm/v0.10.17/lib/node_modules/coffee-script/lib/command.js:15:20)
   at compileScript (/Users/dblock/.nvm/v0.10.17/lib/node_modules/coffee-script/lib/command.js:135:7)
   at /Users/dblock/.nvm/v0.10.17/lib/node_modules/coffee-script/lib/command.js:85:26
   at fs.js:266:14
   at Object.oncomplete (fs.js:107:15)
```

I think I debug this on every single machine. The problem is that the version of CoffeeScript is out of date.

```
$ coffee --version
CoffeeScript version 1.0.1
$ which coffee
/Users/dblock/.nvm/v0.10.17/bin/coffee
```

Run `npm install coffee-script -g`.

```
$ npm install coffee-script -g
npm http GET https://registry.npmjs.org/coffee-script
npm http 304 https://registry.npmjs.org/coffee-script
/Users/dblock/.nvm/v0.10.17/bin/coffee -> /Users/dblock/.nvm/v0.10.17/lib/node_modules/coffee-script/bin/coffee
/Users/dblock/.nvm/v0.10.17/bin/cake -> /Users/dblock/.nvm/v0.10.17/lib/node_modules/coffee-script/bin/cake
coffee-script@1.6.3 /Users/dblock/.nvm/v0.10.17/lib/node_modules/coffee-script
```

Voila.

```
$ coffee --version
CoffeeScript version 1.6.3
```

Problem solved.

Some help from [@craigspaeth](http://twitter.com/craigspaeth).
