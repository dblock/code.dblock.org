---
layout: post
title: Safely Passing Ruby Variables to JavaScript in ERB
date: 2024-10-30 01:00:00
tags: [ruby, security]
comments: true
---
A user [reported a bug](https://github.com/dblock/slack-strava/issues/171) in [Slava](https://slava.playplay.io), a bot that syncs Strava activities to Slack, where they couldn't subscribe to the paid version because their Slack team name contained a quote. That was a rookie mistake on my part in HTML escaping that almost cost me $9.99. Interestingly, it required a rather [non-trivial fix](https://github.com/dblock/slack-strava/commit/3a70e5f70b778a79b79a1406ee629e379b07094e).

The bot's [code](https://github.com/dblock/slack-strava/) extensively uses [ERB](https://github.com/ruby/erb), the standard Ruby templating system. The implementation attempts to render a team name in **bold**. The [recommended way](https://stackoverflow.com/questions/75389277/how-to-make-a-text-bold-in-helper-rb-ruby-file-inside-a-string) to do this is to combine `.html_safe` with the displayed value.

```html
<script>
  $(document).ready(function() {
    message('<%= "Welcome <b>".html_safe + name + "</b>!".html_safe %>');
  });
</script>
```

Aside of being not very elegant, this almost works. Unfortunately, because we are trying to pass an argument into JavaScript the page will be broken if the value of `name` contains a line break.

```html
<script>
  $(document).ready(function() {
    message('<%= "Welcome <b>".html_safe + "line1
line2" + "</b>!".html_safe %>');
  });
</script>
```

So how do we fix that?

First, we try to avoid using the cumbersome `html_safe` by sending a value into a JavaScript variable directly, which lets us reuse it later without having to mix Ruby ERB markup.

```html
<script>
  $(document).ready(function() {
    var name = '<%= name %>';
  });
</script>
```

This looks unsafe, but assuming it works, we can reuse this variable directly.

```html
<script>
  $(document).ready(function() {
    var name = '<%= name %>';
    message('Welcome <b>' + name + '</b>!');
  });
</script>
```

For the same reason as above the page will be broken when the name has a quote, a double quote, or a carriage return. This value must be encoded in a safe manner before rendering it.

The standard ERB way to make a value safe is to escape it with [html_escape](https://apidock.com/rails/v5.2.3/ERB/Util/html_escape), abbreviated as `h`.

```html
<script>
  $(document).ready(function() {
    var name = '<%=h name %>';
    message('Welcome <b>' + name + '</b>!');
  });
</script>
```

This does fix the issue with single and double quotes.

```bash
$ irb

3.3.5 :001 > require 'erb'
3.3.5 :002 > ERB::Util::html_escape("Daniel's Team")
 => "Daniel&#39;s Team"
3.3.5 :003 > ERB::Util::html_escape("\"Daniel's Team\"")
 => "&quot;Daniel&#39;s Team&quot;"
```

However, it will still render a carriage return, causing the following invalid JavaScript with the team name is "line1\nline2".

```js
<script>
  $(document).ready(function() {
    var name = "line 1
line 2";
    message('Welcome <b>' + name + '</b>!');
  });
</script>
```

This is because ERB considers line breaks as safe.

```bash
3.3.5 :001 > ERB::Util::html_escape("line1\nline2")
 => "line1\nline2"
```

We can fix this by converting the safe value to JSON. This will quote and escape it for us, works for `nil`, and will prevent XSS.

```bash
3.3.5 :001 > require 'erb'
3.3.5 :002 > require 'json'
3.3.5 :003 > JSON.generate(ERB::Util::html_escape(nil))
 => "\"\""
3.3.5 :004 > JSON.generate(ERB::Util::html_escape("Daniel's Team"))
 => "\"Daniel&#39;s Team\""
3.3.5 :005 > JSON.generate(ERB::Util::html_escape("\"Daniel's Team\""))
 => "\"line1\\nline2\""
3.3.5 :006 > "\"&quot;Daniel&#39;s Team&quot;\""
 => "\"line1\\nline2\""
3.3.5 :007 > JSON.generate(ERB::Util::html_escape("<script>alert('xss');</script>"))
 => "\"&lt;script&gt;alert(&#39;xss&#39;);&lt;/script&gt;\""
```

The value can thus be rendered directly without extra quotes.

```html
<script>
  $(document).ready(function() {
    var name = <%= JSON.generate(ERB::Util::html_escape(name)) %>;
    message('Welcome <b>' + name + '</b>!');
  });
</script>
```

In Rails, something similar is available as `"<%= j name %>"`, or [escape_javascript](https://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html#method-i-escape_javascript).

See [slack-strava@3a70e5f7](https://github.com/dblock/slack-strava/commit/3a70e5f70b778a79b79a1406ee629e379b07094e) for a complete implementation with tests.
