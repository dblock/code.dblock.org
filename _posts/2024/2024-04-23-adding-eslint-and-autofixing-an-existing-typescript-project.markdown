---
layout: post
title: Adding eslint and Auto-Fixing an Existing TypeScript Project
date: 2024-04-23
tags: [opensearch, javascript, typescript]
comments: true
---
In [opensearch-api-specification#260](https://github.com/opensearch-project/opensearch-api-specification/pull/260) I added [eslint](https://eslint.org/), but had a hard time finding a cookbook for auto-fixing specific violations. Here it is.

First, I followed the [getting started with eslint guide](https://eslint.org/docs/latest/use/getting-started), which essentially tells you to run `npm init @eslint/config@latest`.

Rewrite `eslint.config.mjs` using the newer flat configuration format, making sure that the `ignores` and `rules` section appears last, as it will overwrite the defaults. For my TypeScript project, see the complete file [here](https://github.com/opensearch-project/opensearch-api-specification/blob/main/tools/eslint.config.mjs).

{% highlight javascript %}
export default [
  pluginJs.configs.recommended,
  ...compat.extends('standard-with-typescript'),
  {
    files: ['**/*.{js,ts}'],
    ignores: [
      ...
    ],
    rules: {
      ...
    }
  }
]
{% endhighlight %}

Add the linter to scripts.

{% highlight json %}
"scripts": {
  "lint": "eslint .",
}
{% endhighlight %}

Run the linter with `npm run lint`. My first run resulted in a lot of violations. I exctracted the list of them with `jq` and pasted it into `rules`.

{% highlight bash %}
$ npm run --silent lint -- --format json | jq '.[].messages[] | select(.line != null) .ruleId' | sort | uniq
{% endhighlight %}

{% highlight javascript %}
export default [
  pluginJs.configs.recommended,
  ...compat.extends('standard-with-typescript'),
  {
    rules: {
      '@typescript-eslint/consistent-indexed-object-style': 'warn',
      '@typescript-eslint/consistent-type-assertions': 'warn',
      '@typescript-eslint/dot-notation': 'warn',
      ...
    }
  }
]
{% endhighlight %}

Now, `npm run lint` will execute successfully showing warnings only.

{% highlight bash %}
../tools/test/linter/factories/schema_file.ts
   4:17  warning  Function name `schema_file` must match one of the following formats: camelCase, PascalCase, UPPER_CASE         @typescript-eslint/naming-convention
  10:32  warning  void is not valid as a constituent in a union type                                                             @typescript-eslint/no-invalid-void-type
{% endhighlight %}

To auto-fix, first disable all rules with `off` and enable the one you want to auto-fix with `error`.

{% highlight javascript %}
export default [
  pluginJs.configs.recommended,
  ...compat.extends('standard-with-typescript'),
  {
    rules: {
      '@typescript-eslint/consistent-indexed-object-style': 'off',
      '@typescript-eslint/consistent-type-assertions": 'off',
      '@typescript-eslint/dot-notation": 'error',
    }
  }
]
{% endhighlight %}

Now run `npm run lint -- --fix`. Not all rules have an autofixer, but if yours does it will make the code changes, and you can now remove if rom the config and finally turn back all other rules to `warn`.

Here's my [second pull request](https://github.com/opensearch-project/opensearch-api-specification/pull/265) that fixed most self-correcting violations. 

A word of caution, beware of `--fix`. In the project above the `dot-notation` autofix made a destructive change that caused tests to fail (and that I have yet to debug).
