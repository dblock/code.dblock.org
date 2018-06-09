---
layout: post
title: "The New code.dblock.org Powered by Jekyll"
date: 2015-01-07 16:07:00
tags: [blog, jekyll]
comments: true
---
The newly remodeled [code.dblock.org](https://code.dblock.org) is powered by [Jekyll](http://jekyllrb.com) and [Github pages](https://pages.github.com). The source code can be found [here](https://github.com/dblock/code.dblock.org).

![]({{ site.url }}/images/posts/2015/2015-01-07-the-new-code-dblock-dot-org/meta.png)

### The Old

My [homegrown system](https://github.com/dblock/dblog) was built in 2008. The tech stack was Microsoft ASP.net with a SQL Server back-end. I did most publishing with [Windows LiveWriter](http://en.wikipedia.org/wiki/Windows_Live_Writer) that used [AtomPub](https://code.dblock.org/2009/12/07/implementing-atompub-in-net.html).

Needless to say that was starting to really annoy me, having to boot a VirtualBox VM with Windows on my Mac just to publish an article. Worse, copy paste between the host and the guest OS was not working for images, so I used Dropbox for screenshots. The system was originally designed to save me time, only to ultimately become a time suck. Finally, [WinHost](http://www.winhost.com), where the blog was hosted, while providing excellent service, actually costs quite a bit of money.

### Migration

#### Posts

I had to write [a migration](https://github.com/dblock/dblog-to-jekyll) from the old SQL data to the new markdown format.

ActiveRecord does a good job talking to a SQL server.

{% highlight ruby %}
gem 'activerecord'
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter', '~> 4.0.0'
{% endhighlight %}

I had to fight `tiny_tds` a bit, needing to reinstall `iconv` and `brew install freetds`.

{% highlight ruby %}
require 'rubygems'
require 'bundler'

Bundler.setup :default, :development

require 'yaml'
require 'active_record'
{% endhighlight %}

Create a _database.yml_ configuration file.

{% highlight yaml %}
development:
  adapter: sqlserver
  host: sql.winhost.com
  database: DB_26545
  username: ...
  password: ...
{% endhighlight %}

Connect to the database.

{% highlight ruby %}
dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
{% endhighlight %}

Define models, such as `Post`.

{% highlight ruby %}
class Post < ActiveRecord::Base
  self.table_name = 'Post'
end
{% endhighlight %}

Require the models explicitly.

{% highlight ruby %}
Dir['models/**/*.rb'].each do |f|
  require File.expand_path(f)
end
{% endhighlight %}

Iterate over posts.

{% highlight ruby %}
puts "Reading #{Post.count} post(s) ..."
Post.order('created ASC').each do |post|
  puts "#{post.Slug}: #{post.Title}"
end
{% endhighlight %}

The posts were stored in HTML, I convert them to Markdown with [reverse_markdown](https://github.com/xijo/reverse_markdown).

{% highlight ruby %}
content = ReverseMarkdown.convert(post.Body, github_flavored: true)
{% endhighlight %}

Figure out where to write the post on disk and write the markdown post.

{% highlight ruby %}
  File.open "#{post.Slug}.markdown", "w" do |file|
    file.write <<-EOS
---
layout: post
title: "#{post.Title}"
redirect_from: "/#{post.Slug}"
date: #{post.Created.strftime('%F %T')}
comments: true
---
#{content}
    EOS
{% endhighlight %}

The full script is [here](https://github.com/dblock/dblog-to-jekyll/blob/master/doit.rb).

#### Disqus

I wrote [a script](https://github.com/dblock/dblog-to-jekyll/blob/master/discus_migration_map.rb) to rewrite post URLs for [Disqus](https://disqus.com) comments and uploaded it as [instructed](https://help.disqus.com/customer/portal/articles/286778-migration-tools). Posts appeared after I set the correct `disqus-shortname` in my __config.yml_.

### Jekyll

#### Theme

I picked [Minimal Mistakes](https://mademistakes.com/articles/minimal-mistakes-jekyll-theme) and altered it a bit to remove clutter. Thanks [@mmistakes](https://twitter.com/mmistakes) for the awesome work.

#### Github Limitations

If you're like me and don't want to generate the Jekyll site yourself, be aware that Github pages doesn't support many plugins. This means you can't make features like, for example, tags, to work at the moment. Create a _Gemfile_ that references [github-pages](https://github.com/github/pages-gem) to see an identical output as what Github would show.

{% highlight ruby %}
source 'http://rubygems.org'

gem 'github-pages'
{% endhighlight %}

Serve Jekyll locally via `bundle exec jekyll serve`.

#### Syntax Highlighting

Github pages don't support syntax highlighting the same way all markdown content does on Github. You can't use backticks. This means ```ruby will not syntax highlight Ruby, you have to use Pygments with one of the [very many lexers](http://pygments.org/docs/lexers) to highlight code.

```
{% raw %}
{% highlight ruby %}

# Ruby code goes here

{% endhighlight %}
{% endraw %}
```

#### Tags and Related Posts

None of these will currently work on Github pages, so I removed them from the theme. Add your +1 to [pages-gem#93](https://github.com/github/pages-gem/issues/93).

#### Search

I added Google Custom search [in this commit](https://github.com/dblock/code.dblock.org/commit/942c3603c67d6afe5da06e58aeddc2ac4a8a7815).

#### CNAME

I used `code2.dblock.org` while iterating on the system, then finally updated the CNAME file to make the actual switch. Github custom domains are documented [here](https://help.github.com/articles/about-custom-domains-for-github-pages-sites/).

Finally, I happened to rename the repo a few times from `code` to `code.dblock.org` and back. Github will bring your site down for a while when that happens - you have been warned.

### Contribute

If you see a typo in a post or want to contribute in any other way, please don't hesitate to [open issues and make pull requests](https://github.com/dblock/code.dblock.org/issues).
