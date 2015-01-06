---
layout: post
title: "Implementing AtomPUB in .NET"
redirect_from: "/implementing-atompub-in-net"
date: 2009-12-07 17:02:46
tags: [syndication, codeproject, .net, asp.net, blog]
comments: true
---
I’ve been wanting to implement a POST protocol for my blog for a while. The urge got really bad since I’ve started using [LiveWriter](http://download.live.com/writer) at my [day job](http://www.appsecinc.com/). It’s such a nice piece of software compared to blogging with the online HTML editor with it’s, often too smart, HTML cleanup, struggling with embedded pictures and loosing drafts. I even considered abandoning my own creation and using [WordPress](http://wordpress.org/) or some other blogging engine. Then the "not invented here" syndrome took over. I spent a few hours implementing a large part of AtomPUB, [RFC-5023](http://tools.ietf.org/html/rfc5023).

The [Atom Publishing Protocol](http://bitworking.org/projects/atom/rfc5023.html) is an application-level protocol for publishing and editing web resources. The protocol is based on HTTP transfer of Atom-formatted representations. The Atom format is documented in the Atom Syndication Format, [RFC-4287](http://tools.ietf.org/html/rfc4287).

### Generating Atom Feeds

My current blog implementation supports ATOM. This is done by using an asp:Repeater to which I bind a data set.

```xml
<feed xml:lang="en-us" version="0.3" xmlns="http://purl.org/atom/ns#">
  <title>Title</title>
  <link rel="alternate" type="application/xhtml+xml" href="AtomPost.aspx" />
  <asp:Repeater id="repeater" runat="server">
    <ItemTemplate>
      <entry>
        <id>Post/<%# Eval("Id") %></id>
        <title><%# Renderer.Render(Eval("Title")) %></title>
        <created><%# ((DateTime) Eval("Created")).ToString("s") %></created>
        <modified><%# ((DateTime) Eval("Modified")).ToString("s") %></modified>
        <issued><%# ((DateTime) Eval("Created")).ToString("s") %></issued>
        <author>
          <name>author</name>
        </author>
        <content type="text/html" mode="xhtml">
          <body xmlns="http://www.w3.org/1999/xhtml">
            <![CDATA[
              <%# Eval("Body") %>
            ]]>
          </body>
        </content>
        <link rel="alternate" type="text/html" href='ShowPost.aspx?Id=<%# Eval("Id") %>' />
        <link rel="edit" href='AtomPost.aspx?Id=<%# Eval("Id") %>' />
      </entry>
    </ItemTemplate>
  </asp:Repeater>
</feed>
```

This works fine for generating feeds, but in order to consume ATOM posts I will need an object model for feed items. That’s where the "not invented here" syndrome has to stop and I am going to let [Argotic](http://argotic.codeplex.com/) do the job. First, by rewriting the above ASP.NET code in C#.

```cs
Response.ContentType = "application/atom+xml;charset=\"utf-8\"";

AtomFeed feed = new AtomFeed();
feed.Title = new AtomTextConstruct(Title);

List<Posts> posts = SessionManager.BlogService.GetPosts();

foreach (TransitPost post in posts)
{
  AtomEntry atomEntry = new AtomEntry();
  atomEntry.Title = new AtomTextConstruct(post.Title);
  foreach (TransitTopic topic in post.Topics)
  {
      atomEntry.Categories.Add(new AtomCategory(topic.Name));
  }
  atomEntry.Content = new AtomContent(post.Body, "html");
  atomEntry.PublishedOn = post.Created;
  atomEntry.UpdatedOn = post.Modified;
  atomEntry.Id = new AtomId(new Uri(string.Format("{0}Post/{1}",
      SessionManager.WebsiteUrl, post.Id)));
  atomEntry.Links.Add(new AtomLink(new Uri(string.Format("{0}AtomBlog.aspx?id={1}",
      SessionManager.WebsiteUrl, post.Id)), "edit"));
  AtomLink atomEntryUri = new AtomLink(new Uri(string.Format("{0}ShowPost.aspx?id={1}",
      SessionManager.WebsiteUrl, post.Id)), "alternate");
  atomEntryUri.ContentType = "text/html";
  atomEntry.Links.Add(atomEntryUri);
  feed.AddEntry(atomEntry);
}

feed.Save(Response.OutputStream);
Response.End();
```

### AtomPub Discovery

A client that creates posts must be able to find out where to POST to. This is done by creating a service document and pointing the default blog page to it. Interestingly LiveWriter is a little thick with relative URLs, the href below is actually replaced by full URI in code.

```xml
<link id="linkAtomPost" runat="server" rel="service" type="application/atomsvc+xml" href="AtomSvc.aspx">
```

The service document describes a workspace with collections. We have two: one for posts and another for images. The one for posts includes post categories.

```xml
<service xmlns="http://www.w3.org/2007/app" xmlns:atom="http://www.w3.org/2005/Atom">
  <workspace>
    <atom:title>DBlog.NET</atom:title>
    <collection href="http://localhost/dblog/AtomPost.aspx">
      <atom:title>Posts</atom:title>
      <accept>application/atom+xml;type=entry</accept>
      <categories>
        <atom:category term="category1" />
        <atom:category term="category2" />
      </categories>
    </collection>
    <collection href="http://localhost/dblog/AtomImage.aspx">
      <atom:title>Images</atom:title>
      <accept>image/jpeg</accept>
      <accept>image/gif</accept>
      <accept>image/png</accept>
    </collection>
  </workspace>
</service>
```

We now have Default.aspx that points to the service document, which points to AtomPost.aspx that can generate a feed. The rest doesn’t exist yet, but this is enough to make LiveWriter happy and allow it to register the blog. LiveWriter will automatically detect the Posts collection and, since it’s still a little thick, prompt to which image collection to post images to (we only have one).

### Creating Posts

To create a post we must at least understand a POST request to AtomPost.aspx.

The client is posting an ATOM entry that we must read.

```cs
AtomEntry atomEntry = new AtomEntry();
atomEntry.Load(Request.InputStream);
```

The blog system has objects of type Post that are going to be created. Also note that the post comes with ATOM categories – here you would need to recognize which ones must be created and which ones exist as well as associate the categories with the new post. We’ll omit that code to simplify things.

```cs
Post post = new Post();
post.Id = RequestId;
post.Title = atomEntry.Title.Content;
post.Body = atomEntry.Content.Content;
post.Created = atomEntry.PublishedOn;
post.Modified = atomEntry.UpdatedOn;
post.Id = SessionManager.BlogService.CreateOrUpdatePost(post);
```

The post has been created, the server must respond with 201 Created and a new location for this post.

```cs
Response.ContentType = "application/atom+xml;type=entry;charset=\"utf-8\"";
Response.StatusCode = 201;
Response.StatusDescription = "Created";
string location = string.Format("AtomPost.aspx?id={0}", post.Id);
Response.Headers.Add("Location", location);
Response.Headers.Add("Content-Location", location);
```

We’ll also add metadata that describes the new post ID and location and return the post to the client.

```cs
atomEntry.Id = new AtomId(new Uri(string.Format("Post/{0}", post.Id)));
atomEntry.Links.Add(new AtomLink(new Uri(string.Format("AtomPost.aspx?id={0}", post.Id))));
atomEntry.Links.Add(new AtomLink(new Uri(string.Format("AtomPost.aspx?id={0}", post.Id)), "edit"));
AtomLink atomEntryUri = new AtomLink(new Uri(string.Format("ShowPost.aspx?id={0}", post.Id)), "alternate");
atomEntryUri.ContentType = "text/html";
atomEntry.Links.Add(atomEntryUri);
atomEntry.Save(Response.OutputStream);
```

There’s no more data to be written to the client. Note that this throws a `ThreadAbortException` that must be trapped in the page code.

```
Response.End();
```

### Updating and Retrieving Posts

There’re actually four scenarios to implement in AtomPost.

- **GET** : retrieve all posts – see Generating Atom Feeds code above.
- **GET** with a post ID: retrieve a specific post - a subset of GET for all posts.
- **POST** : create a post – see Creating Posts code above.
- **PUT** with a post ID: update an existing post – see Creating Posts code above.

```cs
switch (Request.HttpMethod)
{
  case "POST":
  case "PUT":
    CreateOrUpdatePost(sender, e);
    break;
  case "GET":
    if (RequestId) {
        GetPost(sender, e);
    }
    else
    {
        GetPosts(sender, e);
    }
    break;
  default:
    throw new NotSupportedException(Request.HttpMethod);
}
```

You can see the complete code for AtomPost [here](https://github.com/dblock/dblog/blob/master/Web/AtomPost.aspx.cs).

### Creating Images

Images are similar to posts, except that image data is never embedded in an Atom entry. An image is simply POSTed as binary data and reused in posts with the location that the server returns.

```cs
Image image = new Image();
image.Id = RequestId;
image.Name = string.Format("{0}.jpg", Request.Headers["Slug"]);
image.Data = new byte[Request.InputStream.Length];
Request.InputStream.Read(image.Data, 0, (int)Request.InputStream.Length);

image.Id = SessionManager.BlogService.CreateOrUpdateImage(SessionManager.Ticket, image);

Response.ContentType = "application/atom+xml;type=entry;charset=\"utf-8\"";
Response.StatusCode = 201;
Response.StatusDescription = "Created";
string location = string.Format("AtomImage.aspx?id={0}", image.Id);
Response.Headers.Add("Location", location);

AtomEntry atomEntry = GetImage(image);
atomEntry.Save(Response.OutputStream);
Response.End();
```

Similarly to AtomPost, AtomImage supports GET, POST and PUT. You can see the full code [here](https://github.com/dblock/dblog/blob/master/Web/AtomImage.aspx.cs).

### Security

All the POST and PUT calls must be authenticated, but I will leave this exercise to your particular system. I use form-based authentication, so I got lazy and did basic authentication in code – it should move out to an authentication provider so that the blog system supports both form-based and basic auth.

### Conclusion

This was pretty easy after-all. It took less time putting this code together than struggling with the HTML editor in the past. And I am now writing this in LiveWriter!

![]({{ site.url }}/images/posts/2009/2009-12-07-implementing-atompub-in-net/image%5b26%5d.jpg)

