- [Contributing to code.dblock.org](#contributing-to-codedblockorg)
    - [Fork the Project](#fork-the-project)
    - [Install Ruby](#install-ruby)
  - [Contribute Content](#contribute-content)
    - [Create a Topic Branch](#create-a-topic-branch)
    - [Add or Edit a Post](#add-or-edit-a-post)
    - [Commit Changes](#commit-changes)
    - [Push](#push)
    - [Make a Pull Request](#make-a-pull-request)
    - [Make Changes](#make-changes)
    - [Rebase](#rebase)
    - [Check on Your Pull Request](#check-on-your-pull-request)
    - [Be Patient](#be-patient)
  - [Thank You](#thank-you)

# Contributing to code.dblock.org

Other than millions of readers, this blog occasionally has [contributors](https://github.com/dblock/code.dblock.org/graphs/contributors).

You're encouraged to submit [pull requests](https://github.com/dblock/code.dblock.org/pulls), [or at least open issues](https://github.com/dblock/code.dblock.org/issues).

In the examples below, substitute your Github username for `contributor` in URLs.

### Fork the Project

Fork the [project on Github](https://github.com/dblock/code.dblock.org) and check out your copy.

```
git clone https://github.com/contributor/code.dblock.org.git
cd code.dblock.org
git remote add upstream https://github.com/dblock/code.dblock.org.git
```

### Install Ruby

Install Ruby. We recommend [rvm](https://rvm.io/). Use Ruby 2.7+.

```
rvm use 2.7.7
```

Install bundler.

```
gem install bundler
```

Install dependencies.

```
bundle install
```

Start a local Jekyll server.

```
bundle exec jekyll serve 
```

Navigate to http://localhost:4000 to see the blog.

## Contribute Content

### Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout gh-pages
git pull upstream gh-pages
git checkout -b my-feature-branch
```

### Add or Edit a Post

Add or edit a post.

Make sure that it displays correctly locally at http://localhost:4000.

### Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Writing good commit logs is important. A commit log should describe what changed and why.

```
git add ...
git commit
```

### Push

```
git push origin my-feature-branch
```

### Make a Pull Request

Go to https://github.com/contributor/code.dblock.org and select your feature branch. Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

### Make Changes

Make changes as/if requested.

You can amend your previous commit and force push the changes or commit a new change.

```
git add .
git commit --amend
git push origin my-feature-branch -f
```

### Rebase

If you've been working on a change for a while, rebase with upstream/gh-pages.

```
git fetch upstream
git rebase upstream/gh-pages
git push origin my-feature-branch -f
```

### Check on Your Pull Request

Go back to your pull request after a few minutes and see whether it passed muster. Everything should look green, otherwise fix issues and amend your commit as described above.

### Be Patient

It's likely that your change will not be merged and that the nitpicky maintainer will ask you to do more, or fix seemingly benign problems. Hang on there!

## Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
