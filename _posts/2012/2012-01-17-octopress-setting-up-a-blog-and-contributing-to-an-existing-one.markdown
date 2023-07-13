---
layout: post
title: "Octopress: Setting up a Blog and Contributing to an Existing One"
redirect_from: "/octopress-setting-up-a-blog-and-contributing-to-an-existing-one/"
date: 2012-01-17 15:22:24
tags: [octopress, technology, blog]
comments: true
dblog_post_id: 309
---
[Octopress](http://octopress.org) documentation can be quite confusing. It took me a while to understand what the heck Octopress is doing to branches and remote origins. It’s actually pretty simple, so I am going to try to un-confuse you. I will also show you a better way to contribute to an existing blog and explain what’s happening in those Rake tasks.

We are going to deploy a blog to Github pages, so we need a project, such as _username.github.com_. Go to Github to create one. Use your username instead of "username".

Next, fetch Octopress and install it locally. This gets the files from its main repository and applies a default theme.

```
$ git clone git://github.com/imathis/octopress.git octopress

Cloning into octopress...
remote: Counting objects: 6046, done.
remote: Compressing objects: 100% (2420/2420), done.
remote: Total 6046 (delta 3448), reused 5549 (delta 3097)
Receiving objects: 100% (6046/6046), 1.26 MiB | 426 KiB/s, done.
Resolving deltas: 100% (3448/3448), done.

$ cd octopress
Using /home/dblock/.rvm/gems/ruby-1.9.2-p290

octopress$ bundle install
Fetching source index for https://rubygems.org/
...
Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.

octopress$ rake install

## Copying classic theme into ./source and ./sass
```

Octopress comes with some handy Rake tasks to get you started. To deploy to Github pages run `rake setup_github_pages`. When prompted, enter the GIT URL to your new repository, such as git@github.com:username/username.github.com.git.

```
octopress$ rake setup_github_pages
Enter the read/write url for your repository: git@github.com:username/username.github.com.git

Added remote git@github.com:username/username.github.com.git as origin
Set origin as default remote
Master branch renamed to 'source' for committing your blog source files
Initialized empty Git repository in /home/username/source/octopress/_deploy/.git/
[master (root-commit) 2a4e9e7] Octopress init
1 files changed, 1 insertions(+), 0 deletions(-)
create mode 100644 index.html

---
## Now you can deploy to https://username.github.com with `rake deploy` ##
```

So what the heck happened here? It pointed our clone to our new repository. It also created a __deploy_ directory with another git repository that is going to contain everything that is being deployed. The remote in that directory is the same as the one in our _octopress_ directory, but the checked out branch is _master_. Btw, we’re now on the _source_ branch.

```
octopress$ git remote -v
octopress    git://github.com/imathis/octopress.git (fetch)
octopress    git://github.com/imathis/octopress.git (push)
origin    git@github.com:username/username.github.com.git (fetch)
origin    git@github.com:username/username.github.com.git (push)

octopress$ git branch
* source

octopress$ cd _deploy/
octopress/_deploy$ git remote -v
origin    git@github.com:username/username.github.com.git (fetch)
origin    git@github.com:username/username.github.com.git (push)

octopress/_deploy$ git branch
* master

octopress/_deploy$ cd ..

octopress$
```

Now is a good time to read [Blogging Basics](http://octopress.org/docs/blogging/). You should edit __config.yml _with your blog name, etc. Let's create an article and deploy it.

```
octopress$ rake new_post["New Post"]

Creating new post: source/_posts/2012-01-17-new-post.markdown
```

Edit the generated file and add some text at the bottom.

Generate the blog.

```
octopress$ rake generate
## Generating Site with Jekyll
directory source/stylesheets/
  create source/stylesheets/screen.css
Configuration from /home/dblock/source/o/octopress/_config.yml
Building site: source -> public
Successfully generated site: source -> public
```

You can also preview it with `rake preview`.

Before we deploy the blog, save the source and push it to Github. Note that we’re pushing our source branch.

```
octopress$ git add .

octopress$ git commit -m "Initial blog post."
...

octopress$ git push origin source
Counting objects: 3927, done.
Compressing objects: 100% (1412/1412), done.
Writing objects: 100% (3927/3927), 910.08 KiB, done.
Total 3927 (delta 2257), reused 3848 (delta 2203)
To git@github.com:username/username.github.com.git
* [new branch]      source -> source
```

You’ll have to repeat the above every time you make changes, to save them.

Deploy the blog. What this does it rake everything inside __deploy_ and push it onto the _master_ branch.

```
octopress$ rake deploy

## Pushing generated _deploy website
Counting objects: 84, done.
Compressing objects: 100% (74/74), done.
Writing objects: 100% (84/84), 180.40 KiB, done.
Total 84 (delta 2), reused 0 (delta 0)
To git@github.com:username/username.github.com.git
* [new branch]      master -> master
```

If you go to https://username.github.com you should see your blog with the blog post once Github has regenerated the pages – usually a minute or two. And on https://github.com/username/username.github.com you should be able to see the generated files on _master_ along with a _source_ branch with the blog source.

You’ll have to do this every time you want to deploy your changes.

So how does one start contributing to an existing Octopress blog (or yourself from a new computer)? What we want is the same setup as above, but not from scratch.

```
$ git clone git@github.com:username/username.github.com.git
$ cd username.github.com
username.github.com$ git checkout source
username.github.com$ mkdir _deploy
username.github.com$ cd _deploy
username.github.com/_deploy$ git init
username.github.com/_deploy$ git remote add origin git@github.com:username/username.github.com.git
username.github.com/_deploy$ git pull origin master
username.github.com/_deploy$ cd ..
username.github.com$
```

You’re all set. Create posts and stuff. Happy blogging with Octopress.
