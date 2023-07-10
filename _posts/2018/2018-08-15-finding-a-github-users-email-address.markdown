---
layout: post
title: "Finding a Github User's E-Mail Address"
date: "2018-08-15"
tags: [graphql, github]
---
If you are like me, [trying to hire developers](https://www.artsy.net/jobs), you've long mastered the dark art of digging up their e-mail address from social media, LinkedIn and, most importantly, Github for the purposes of reaching out directly. The latter consists of finding an old source repo and running a `git log` on it. Most Github users have used a real e-mail address when making their first commits with git. Privacy be damned.

## Fue

Introducing [fue](https://github.com/dblock/fue), a little command-line tool to do just that. Get a Github access token [here](https://github.com/settings/tokens). Fue is short for "Finding Unicorn Engineers".

![]({{site.url}}/images/posts/2018/2018-08-15-finding-a-github-users-email-address/fue.gif)

## Implementation Details

The [Github V4 GraphQL API](https://docs.github.com/en/graphql) lets you make one deep query without having to iterate over repositories or commits.

### Finding a User ID

A first query gets us the user ID.

{% highlight js %}
query($login: String!) {
  user(login: $login) {
    id
  }
}
{% endhighlight %}

### Enumerating Root Repositories

The second query gets us all root repositories with their commit histories for the user ID obtained above.

{% highlight js %}
query($login: String!, $author_id: ID!, $depth: Int!) {
  user(login: $login) {
    repositories(last: $depth, isFork:false, privacy: PUBLIC) {
      edges {
        node {
          defaultBranchRef {
            target {
              ... on Commit {
                history(first: 1, author: { id: $author_id }) {
                  nodes {
                    author {
                      email
                      name
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
{% endhighlight %}

There's no API to retrieve a user by ID or to retrieve commits for a login, so this may seem a bit cumbersome.

### Open-Source

Fue is open-source, please [contribute to it](https://github.com/dblock/fue).
