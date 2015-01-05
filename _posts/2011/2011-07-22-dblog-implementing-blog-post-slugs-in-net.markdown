---
layout: post
title: "DBlog: Implementing Blog Post Slugs in .NET"
redirect_from: "/dblog-implementing-blog-post-slugs-in-net"
date: 2011-07-22 00:52:32
tags: [.net, asp.net]
comments: true
---
I was showing some [Coffeescript](http://jashkenas.github.com/coffee-script/) to a candidate today. It happened to be a [Backbone.js](http://documentcloud.github.com/backbone/) model with a field called _slug_. "What’s a slug?" – he asked.

A slug is an external identity to an object reachable by an API call. For example, Steven Assael’s amazing graphite drawing entitled "Amber with Peacock Feathers" has a "_steven-assael-amber-with-peacock-feathers"_ slug. Slugs are much more readable than a database object identity, such as _"4dc706fb46895e000100128f"_. They make URLs prettier and helps search engines index data. Slugs also enable developers to change the way data is stored. In general, I recommend hiding internal IDs and creating external IDs for every object that is exposed to the outside world.

In Ruby we use the [mongoid-slug](https://github.com/papercavalier/mongoid-slug) gem. To set this up we include _Mongoid::Slug_ and specify which field to use to generate it.

```ruby
class Artwork
  include Mongoid::Document
  include Mongoid::Slug
  
  field :title, type: String  
  slug :title, index: true
  
  ...
 
end
```

I decided to implement the same thing for this blog, which is a bit obsolete architecture-wise and is written in ASP.NET. To keep things simple, I added a slug field to my _Post_ model as an _nvarchar(256) _and slapped a unique key constraint on it. To generate an actual slug from a title I stole some code from [here](http://www.intrepidstudios.com/blog/2009/2/10/function-to-generate-a-url-friendly-string.aspx). It basically strips any non-alphanumeric text from the post’s title.

```cs
/// <summary>
/// Transform a string into a slug.
/// See http://www.intrepidstudios.com/blog/2009/2/10/function-to-generate-a-url-friendly-string.aspx
/// </summary>
/// <param name="s"></param>
/// <returns></returns>
public static string ToSlug(string s)
{
    s = s.ToLower();
    // invalid chars, make into spaces
    s = Regex.Replace(s, @"[^a-z0-9\s-]", "");
    // convert multiple spaces/hyphens into one space       
    s = Regex.Replace(s, @"[\s-]+", " ").Trim();
    // hyphens
    s = Regex.Replace(s, @"\s", "-");
    return s;
}
```

Slugs are unique, so we must avoid duplicates. While there’re more effective approaches to generating a unique slug, we’ll simply iterate until we find a unique value. After all, how often do we need to generate a new slug?

```cs
public void GenerateSlug(ISession session)
{
    if (! string.IsNullOrEmpty(Slug))
        return;
 
    String slug_base = Renderer.ToSlug(Title);
    String slug_candidate = "";
    int slug_count = 0;
    Post existing_post = null;
 
    do
    {
        slug_candidate = slug_base + (slug_count == 0 ? "" : string.Format("-{0}", slug_count));
        existing_post = session.CreateCriteria(typeof(Post))
            .Add(Expression.Eq("Slug", slug_candidate))
            .Add(Expression.Not(Expression.Eq("Id", this.Id)))
            .UniqueResult<Post>();
        slug_count += 1;
    } while (existing_post != null);
 
    Slug = slug_candidate;
}
```

The routing is a bit trickier. Until now the posts were accessible as _ShowPost.aspx?id=Integer_. I started by making a change where a post can be fetched by slug, such as _ShowPost.aspx?slug=String_. The next problem is accepting slugs in the URL and internally rewriting the ASP.NET request path to the latter. The best place to do it seems to be _Application_BeginRequest _in _Global.asax.cs_.

```cs
string path = Request.Path.Substring(Request.ApplicationPath.Length).Trim("/".ToCharArray());
if (! string.IsNullOrEmpty(path))
{
    // rewrite a slug link to a ShowPost.aspx internal url
    if (path.IndexOf('.') < 0)
    {
        string[] parts = Request.Path.Split('/');
        string slug = parts[parts.Length - 1];
        if (! String.IsNullOrEmpty(slug))
        {
            HttpContext.Current.RewritePath(string.Format("ShowPost.aspx?slug={0}", slug));
        }
    }
}
```

First, we’re removing the virtual path from the request URL, stripping the _/blog/_ part from applications hosted at a _/blog/_ virtual directory. Then, we’re going to assume that anything that doesn’t have a period (.) in the URL is a slug and is being redirected to _ShowPost.aspx_. An alternative is to rely on a _/posts/_ path, but that will break all relative URLs in my existing application since, for example, _/Style.css_ is not the same as _/posts/Style.css_. Naturally your mileage may vary depending on your existing requirements.

Secondly, we’d like to permanently redirect anyone with a _ShowPost.aspx?id=Integer_ link to the new slugged URL and anyone directly hitting the _ShowPost.aspx?id=slug_ url to the slug itself. This way there’s only one way to address a post, by it’s slug.

```cs
// rewrite ShowPost.aspx link to a slug
if (path == "ShowPost.aspx" && !string.IsNullOrEmpty(Request["id"]))
{
    // fetch the post, its slug and permanently redirect to it
}
// rewrite a slug link
else if (path == "ShowPost.aspx" && !string.IsNullOrEmpty(Request["slug"]))
{
    Response.RedirectPermanent(Request["slug"]);
}
```

Here’s a URL that I get after running a task to re-slug all existing posts to my infamous Github is Your New Resume post. It’s a lot nicer!

[code.dblock.org/github-is-your-new-resume](http://code.dblock.org/github-is-your-new-resume)

The URL has changed, yet Discus comments are fine (phew.) – they use my unique identifier. The twitter RT count is lost though and is reset at zero, since Twitter is a URL-based system. Too bad, here’s a screenshot for the memories.

![image]({{ site.url }}/images/posts/2011/2011-07-22-dblog-implementing-blog-post-slugs-in-net/image%5b7%5d.jpg)

314 RTs, holy crap! This blog’s source code is available under the MIT license [on Github](http://github.com/dblock/dblog).
