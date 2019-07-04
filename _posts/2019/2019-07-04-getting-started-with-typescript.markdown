---
layout: post
title: "Getting Started with Typescript"
tags: [typescript, javascript]
date: 2019-07-04
comments: true
---
I've [done](https://code.dblock.org/tags/javascript/) a fair amount of JavaScript, here and there, and have written some TypeScript, too. But I've never actually _started_ anything in TypeScript. Attempting a basic "hello world" in TypeScript turned out to be completely non-trivial, so this should help you.

### Editor

I use [Visual Studio Code](https://code.visualstudio.com).

### Node

Setup node.js. I use [nvm](https://github.com/nvm-sh/nvm#installation-and-update), whatever recent version of node and [npm](https://www.npmjs.com/get-npm).

{% highlight bash %}
$ node --version
v12.1.0

$ npm --version
6.9.0
{% endhighlight %}

### Ts-Node

TypeScript comes with an execution and REPL for node.js called [ts-node](https://www.npmjs.com/package/ts-node).

{% highlight bash %}
$ npm install -g typescript ts-node

$ ts-node --version
v8.3.0
{% endhighlight %}

### Hello World

Create a file called `hello.ts`. It's JavaScript disguised as TypeScript for now. 

{% highlight ts %}
console.log('hello world');
{% endhighlight %}

Run it.

{% highlight bash %}
$ ts-node hello.ts 
hello world
{% endhighlight %}

Underneath `ts-node` this file got transpiled into JavaScript with `tsc hello.ts`, the TypeScript compiler and executed. We can do this ourselves as follows.

{% highlight bash %}
$ tsc hello.ts

$ node hello.js
hello world
{% endhighlight %}

### Asynchronous Code

Let's write a basic function that returns a value.

{% highlight js %}
function f() {
  return "returned from f"
}

console.log(f());
{% endhighlight %}

Make it asynchronous by returning a promise. You can run this with `node async-function.js`.

{% highlight js %}
function f() {
  return new Promise(function(resolve, reject) {
    setTimeout(function() {
      resolve("returned from f after a second");
    }, 1000);
  });
}

f().then(function(result) { 
  console.log(result); 
});
{% endhighlight %}

Now we can rewrite this in TypeScript and use [ES6 fat arrows](https://www.sitepoint.com/es6-arrow-functions-new-fat-concise-syntax-javascript/). We add a _type_ to `f()`, expressing that the function must promise (return a `Promise`) to return a `string`. We mark everything asynchronous with `async`, and use `await` to wait for the asynchronous `f` to finish. 

{% highlight ts %}
async function f(): Promise<string> {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve("returned from f after a second");
    }, 1000);
  });
}

async function main() {
  const result = await f()
  console.log(result);
}

main();
{% endhighlight %}

The `async`/`await` pair is a lot nicer than having to use `then` and having types removes all the guesswork from what functions return.

If you just run this with `ts-node` without any arguments you will have a few issues.

{% highlight bash %}
error TS2705: An async function or method in ES5/ES3 requires the 'Promise' constructor.
error TS2585: 'Promise' only refers to a type, but is being used as a value here.
{% endhighlight %}

These are fixed by calling the compiler with `--lib es6`.

{% highlight bash %}
error TS2304: Cannot find name 'setTimeout'.
error TS2584: Cannot find name 'console'. 
{% endhighlight %}

These are fixed by including a target library with `--lib dom`.

Both arguments are required to run our code with `ts-node`.

{% highlight bash %}
$ ts-node -O '{"lib":["dom","es6"]}' async-function.ts
returned from f after a second
{% endhighlight %}

### Config

Having to specify `-O` with a JSON for every invocation of `ts-node` is annoying. You can create a file called `tsconfig.json` with this configuration.

{% highlight json %}
{
  "compilerOptions": {
  "lib": [
    "es6",
    "dom"
  ]
  }
}
{% endhighlight %}

It gets loaded automatically.

{% highlight bash %}
$ ts-node async-function.ts 
returned from f after a second
{% endhighlight %}

### Adding Lodash

{% highlight bash %}
$ npm install --save lodash @types/lodash 
{% endhighlight %}

Better, create a `package.json` and run `npm install`.

{% highlight json %}
{
  "name": "typescript-hello-world",
  "version": "1.0.0",
  "dependencies": {
  "@types/lodash": "^4.14.53",
  "lodash": "^4.12.0"
  }
}
{% endhighlight %}

This creates `node_modules/lodash` and `node_modules/@types/lodash`, which includes lodash TypeScript definitions.

Now that we have dependencies we can introduce some project structure. The code should live in `src/index.ts`.

{% highlight ts %}
import * as _ from "lodash";

async function f(): Promise<string> {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve("returned from f after a second");
    }, 1000);
  });
}

async function main() {
  const results = await Promise.all(_.times(3, f));
  console.log(results);
}

main();
{% endhighlight %}

And an updated `tsconfig.json`.

{% highlight json %}
{
  "include": [
    "src/**/*"
  ],
    "exclude": [
    "node_modules",
  ],
  "compilerOptions": {
    "lib": [
      "es6",
      "dom",
    ]
  }
}
{% endhighlight %}

Run it.

{% highlight bash %}
$ ts-node src/index.ts 
[
  'returned from f after a second',
  'returned from f after a second',
  'returned from f after a second'
]
{% endhighlight %}

### Links

The code for this post can be found [here](https://github.com/dblock/typescript-hello-world).

