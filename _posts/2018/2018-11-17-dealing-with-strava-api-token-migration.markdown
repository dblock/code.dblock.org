---
layout: post
title: "Dealing with Strava API OAuth Token Migration"
date: 2018-11-17
tags: [strava, oauth, api]
comments: true
---
Strava has recently [announced](https://developers.strava.com/docs/oauth-updates/) changes to the Strava OAuth flow. On October 15, 2019 all applications using the old flow will stop working.

In short, long lived tokens are no longer supported and you must obtain a _refresh token_ that gives you a short-lived _access token_. As long as you are holding a valid _access token_ you may be getting a newer _refresh token_, too.

On the plus side, short lived tokens are good for security, since a leaked access token expires quickly. Refresh tokens are good for security because they never have to leave your app. Finally, tokens get more granular permission scopes, reducing data exposure. The downside is additional burden on the developer and additional security risk for non-interactive applications (see below).

### Migrating my Strava Slack Bot

My [Strava Slack Bot](https://slava.playplay.io) is a classic OAuth application in which users connect their account to Strava in Slack. The migration involved the following.

1. Before we stored a user's `access_token` and `token_type`, now we store a `refresh_token`, `access_token`, `token_type` and `token_expires_at`.
2. Before we made Strava API calls using `acess_token`, now we have to check the token expiration time and potentially refresh `access_token`.
3. Refreshing the token involves a `POST` to `https://www.strava.com/oauth/token` with a `refresh_token` and storing the updated `access_token` with a new `token_expires_at` as well as a potentially changed `refresh_token`. An old `access_token` can be used here during the migration period instead of a `refresh_token`.

Works as intended. See [slack-strava@96b934](https://github.com/dblock/slack-strava/commit/96b93410a8a2c1ff0f58ab79248070a5fe4b10cb) for complete implementation details.

### Migrating my Github Pages Site

My [run.dblock.org](https://run.dblock.org) website has a Travis-CI job that fetches runs from Strava as described in [this blog post](/2018/02/17/auto-publishing-strava-runs-to-github-pages.html). Migrating this task was a little bit more complicated.

The [app settings page](https://www.strava.com/settings/api) no longer carries a long lived access token. The old one will expire in October 2019.

The first step is to obtain an OAuth token with `activity:read_all` scope. Because mine is not an interactive app I used [strava-oauth-token](https://github.com/dblock/strava-ruby-client/blob/master/bin/strava-oauth-token) that makes the API calls and navigates to a web page using a browser.

{% highlight bash %}
$ gem install strava-ruby-client

$ STRAVA_CLIENT_ID=... STRAVA_CLIENT_SECRET=... strava-oauth-token
{% endhighlight %}

Instead of setting `STRAVA_API_TOKEN` we now need `STRAVA_CLIENT_ID` and `STRAVA_CLIENT_SECRET` in the Travis-CI configuration as well as `STRAVA_API_REFRESH_TOKEN` from above to obtain the actual access token each time the website cron runs. However, the result may yield a new refresh token that will need to be rotated, so entering the refresh token in the Travis-CI UI is not going to work.

We can encrypt and store the token in `.travis.yml`.

{% highlight bash %}
$ travis encrypt STRAVA_API_REFRESH_TOKEN=... --add env
{% endhighlight %}

The script that refreshes the token will encrypt a new value if necessary in [run.dblock.org@2af902](https://github.com/dblock/run.dblock.org/commit/2af902f3880900bbe5ac24713d04ca89636f0c27). And we already have code that commits changes to Github.

### If Someone at Strava is Reading

The migration for OAuth apps makes total sense. The migration for an application that doesn't require interaction is both annoying and less secure for two reasons.

1. The application now needs to store a client ID and secret at runtime in order to obtain a refreshed access token. Before it only stored a single long lived access token.
2. The developer is forced to store the refresh token in potentially less secure ways and is now required to store an updated refresh token at "runtime" after obtaining an access token.

I think the Strava developer UI should just let you create a long lived personal access token with any given scope that can be revoked from the same UI, which is what Github API allows for non-interactive apps. Storing that token would be more secure than having to store a client ID and secret.
