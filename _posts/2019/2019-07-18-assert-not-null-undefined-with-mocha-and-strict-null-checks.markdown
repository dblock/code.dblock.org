---
layout: post
title: "Asserting Existence with Mocha, Chai and TypeScript Strict Null Checks"
tags: [typescript, javascript, mocha, chai]
date: 2019-07-18
comments: true
---
I recently encountered a unit test that looked like this.

{% highlight typescript %}
describe("Spline", () => {
  const spline = new Spline();

  it("can be reticulated", () => {
    const reticulatedSpline = spline.reticulate();
    if (! reticulatedSpline) {
      throw new Error('missing a spline');
    }
    expect(reticulatedSpline.reticulatedCount).to.eq(1);
  });
});
{% endhighlight %}

The use of branching and conditionals in tests is an anti-pattern since we want tests to be predictable, each test to focus on a single code execution path and generally keep things simple.

The obvious solution is to replace the conditional with `.to.not.be.null` or `.to.not.be.undefined` or the catch-all `.to.exist` (less cognitive overhead). So why was this code written using an `if` and `throw` in the first place?

The answer is that asserting existence of the object here causes TypeScript `error TS2532: Object is possibly 'undefined'.`.

{% highlight typescript %}
it("can be reticulated", () => {
  const reticulatedSpline = spline.reticulate();
  expect(reticulatedSpline).to.exist;
  expect(reticulatedSpline.reticulatedCount).to.eq(1); // causes TS2532
});
{% endhighlight %}

This is because [the implementation in chai](https://github.com/chaijs/chai/blob/master/lib/chai/assertion.js#L133) creates an assertion object and evaluates it, then an error is thrown if the assertion fails. TypeScript can't infer that the `.to.exist` check will throw if the object is null. 

### Assert Not Null

The first solution is a more elegant variation if the original `if` and `throw`.

{% highlight typescript %}
describe("with extracting assertNotNull", () => {
  function assertNotNull<T>(v: T | null): T {
    if (!v) throw new Error();

    return v;
  }

  it("can be reticulated", () => {
    const reticulatedSpline = spline.reticulate();
    assertNotNull(reticulatedSpline);
    expect(reticulatedSpline!.reticulatedCount).to.eq(1);
  });
});
{% endhighlight %}

Unfortunately, TypeScript as of now doesn't infer the conditional inside a function, either, so, you need to wrap the call and ensure it returns an object to make this option work.

{% highlight typescript %}
describe("with extracting assertNotNull", () => {
  function assertNotNull<T>(v: T | null): T {
    if (!v) throw new Error();

    return v;
  }

  it("can be reticulated", () => {
    const reticulatedSpline = assertNotNull(spline.reticulate());
    expect(reticulatedSpline!.reticulatedCount).to.eq(1);
  });
});
{% endhighlight %}

We get an error instead of an assertion.

{% highlight bash %}
  1) Spline
     with extracting assertNotNull
     can be reticulated:
   
  Error: 
    at assertNotNull (test/spline.spec.ts:17:21)
    at Context.it (test/spline.spec.ts:23:33)

{% endhighlight %}

### Improving Errors

We can augment `assertNotNull` with an `expect` to get a proper assertion failure instead of an error.

{% highlight typescript %}
describe("with expect inside the assert", () => {
  function assertNotNull<T>(v: T | null): T {
    expect(v).to.exist;
    if (!v) throw new Error();
  
    return v;
  }
  
  it("can be reticulated", () => {
    const reticulatedSpline = assertNotNull(spline.reticulate());
    expect(reticulatedSpline!.reticulatedCount).to.eq(1);
  });
});
{% endhighlight %}

The result is better.

{% highlight bash %}
  2) Spline
     with expect inside the assert
     can be reticulated:
   AssertionError: expected null to exist
    at assertNotNull (test/spline.spec.ts:30:19)
    at Context.it (test/spline.spec.ts:37:33)
{% endhighlight %}

### Allowing Null

Finally, we can use TypeScript `!` and explicitly check `.to.exist`.

{% highlight typescript %}
describe("allowing null", () => {
  it("can be reticulated", () => {
    const reticulatedSpline = spline.reticulate();
    expect(reticulatedSpline).to.exist;
    expect(reticulatedSpline!.reticulatedCount).to.eq(1);
  });
});
{% endhighlight %}

This is my preferred method, but requires disabling `strictNullChecks` in tests (read more about this [here](https://basarat.gitbooks.io/typescript/docs/options/strictNullChecks.html)).

The result, in my opinion, is the cleanest.

{% highlight bash %}
  3) Spline
     allowing null
     can be reticulated:
   AssertionError: expected null to exist
    at Context.it (test/spline.spec.ts:45:35)
{% endhighlight %}

### Links

* [stackoverflow#57066536](https://stackoverflow.com/questions/57066536/how-can-i-avoid-an-if-else-in-typescript-with-mocha-and-undefined-returns): How can I avoid an if/else in TypeScript with mocha and undefined returns?
* [sample code from above](https://github.com/dblock/typescript-mocha-strict-null-checks)
