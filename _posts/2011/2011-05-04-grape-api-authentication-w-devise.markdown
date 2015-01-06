---
layout: post
title: "Grape: API Authentication w/ Devise"
redirect_from: "/grape-api-authentication-w-devise/"
date: 2011-05-04 16:26:05
tags: [rails, ruby, security]
comments: true
---
Now that we have dealt with exceptions in our API we need to provide various methods of authentication. We’re going to be talking [grape](https://github.com/intridea/grape) and [devise](https://github.com/plataformatec/devise).

There’re several scenarios and issues to consider.

1. We want some public APIs not to require authentication or registration at all. In our case this is only _ping_, the idea being that an absolute minimum set of code runs underneath.
2. We want public APIs that require the caller to register an application. This gives us some ability to do accounting as well as to block a misbehaving application in the wild.
3. We want users to be able to login via OAuth2 and we’d like to distinguish users between administrators and other types of users.
4. When a user is logged into the website with a form, we’d like to allow browsing and exercising the API without having to do OAuth.

Here’s what we did. It’s far from ideal, please comment and suggest ways to move forward, especially if you think something belongs in Grape or Devise proper.

#### No Authentication

No authentication is easy. We don’t do anything.

```ruby
get "ping" do
  "pong"
end
```

#### A User Logged in with a Form

A previously logged in user is authenticated with Devise (based on Warden). There’s nothing special to do for the API except to insert an _authenticated_user_ method in those APIs that require it.

```ruby
get "me" do
  authenticated_user
  current_user.as_json
end
```

The authenticated_user method uses warden.

```ruby
def authenticated
  if warden.authenticated?
    return true
  else
    error!('401 Unauthorized', 401)
  end
end

def current_user
  warden.user
end
```

#### Client Applications

We have a straightforward way to register _ClientApplications_ which yield an application _ID_ and _secret key_. Both are generated as random hashes. Somewhere in the registration process an administrator approves an app and gives the user who owns the app access to these values.

#### Access Grants

Before we hookup user authentication, note that we have multiple authentication schemes that yield some kind of access. We can all it an _AccessGrant_. We want the grant to expire. We’ll store the grant in the back-end so that we can check the grant after it has been handed out. A future version may improve on this by signing and serializing the grant to the client, therefore avoiding the database hit.

```ruby
class AccessGrant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :code, :type => String
  field :access_token, :type => String
  field :refresh_token, :type => String
  field :access_token_expires_at, :type => Time

  referenced_in :user
  referenced_in :application, :class_name => "ClientApplication"

  def self.find_access(access_token)
    where(:access_token => access_token).
      any_of(
             {:access_token_expires_at => nil},
             {:access_token_expires_at.gt => Time.now}).first
  end

  before_create :gen_tokens

  def self.prune!
    where(:created_at.lt => 3.days.ago).delete_all
  end

  def self.authenticate(code, application_id)
    where(:code => code, :application_id => application_id).first
  end

  def start_expiry_period!
    self.update_attribute(:access_token_expires_at, 2.days.from_now)
  end

  def redirect_uri_for(redirect_uri)
    if redirect_uri =~ /\?/
      redirect_uri + "&code=#{code}&response_type=code"
    else
      redirect_uri + "?code=#{code}&response_type=code"
    end
  end

  protected

  def gen_tokens
    self.code, self.access_token, self.refresh_token = SecureRandom.hex(16), SecureRandom.hex(16), SecureRandom.hex(16)
  end

end
```

#### XApp

Our simpler scenario includes registered applications making calls without users being logged in. [@sarcilav](http://github.com/sarcilav) labeled this _XApp_.

To get an XApp token one would call the _xapp_token_ API method with the client _ID_ and _secret_. The authenticated method will now look for an _xapp_token_ parameter.

```ruby
get "xapp_token" do
  application = ClientApplication.authenticate(params[:client_id], params[:client_secret])
  error!("401 Unauthorized", 401) if application.nil?
  AccessGrant.prune!
  access_grant = AccessGrant.create(:application => application)
  error!("401 Unauthorized", 401) if access_grant.new_record?
  access_grant.start_expiry_period!
  {
      :xapp_token => access_grant.access_token,
      :refresh_token => access_grant.refresh_token,
      :expires_in => access_grant.access_token_expires_at
  }
end

def authenticated
  if warden.authenticated?
    return true
  elsif params[:xapp_token] and
      AccessGrant.find_access(params[:xapp_token])
    return true
  else
    error!('401 Unauthorized', 401)
  end
end
```

This is an improvement over schemes like BASIC authentication. We’re only sending actual credentials (client ID and secret) once during authentication, which would happen under SSL. If subsequent unprotected traffic were to be logged and the logs stolen, the XApp token would have a limited value since it expires.

We found that the XApp authentication model is ideal for client apps that don’t require user registration.

#### OAuth2

OAuth2 is the preferred mechanism for authenticating users. It takes the login out of the hands of the client application – login happens in an external browser, therefore offering the best protection to the user.

Let's start from the the tail-end. Assume the client application has gotten some kind of _access_token _and can pass it to each API. This should allow us to lookup an access grant and eventually a user. Let's add this to the User model.

```ruby
def self.find_for_token_authentication(params = {})
  access = AccessGrant.find_access(params["access_token"])
  return access.user if access
end
```

How does a user obtain such a token with OAuth2? We’ll need two routes.

```ruby
match '/oauth2/authorize'    => 'oauth#authorize',    :via => [:get, :post]
match '/oauth2/access_token' => 'oauth#access_token', :via => [:get, :post]
```

OAuth2 starts by redirecting users to _/oauth2/authorize?client_id=[client id]&redirect_uri=[redirect url]&response_type=code_. This should render a login page. If the user chooses to login, he will be redirected back to the redirect url specified with the authorization code. The application should make a request to _/oauth2/access_token?client_id=[client id]&client_secret=[client secret]&redirect_uri=[redirect url]&grant_type=[authorization code]&code=code_ which will return the JSON `{ "access_token": [access token], "refresh_token": [refresh token], "expires_in": "yyyy-mm-ddThh:mm:ss TZ" }`.

```ruby
class OauthController < ApplicationController

  before_filter :authenticate_user!, :except => [:access_token]
  skip_before_filter :verify_authenticity_token, :only => [:access_token]

  def authorize
    AccessGrant.prune!
    access_grant = current_user.access_grants.create(:application => get_application)
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
  end

  def access_token
    application = ClientApplication.authenticate(params[:client_id], params[:client_secret])
    if application.nil?
      render :json => {:error => "Could not find application"}
      return
    end
    access_grant = AccessGrant.authenticate(params[:code], application.id)
    if access_grant.nil?
      render :json => {:error => "Could not authenticate access code"}
      return
    end
    access_grant.start_expiry_period!
    render :json => {
        :access_token => access_grant.access_token,
        :refresh_token => access_grant.refresh_token,
        :expires_in => access_grant.access_token_expires_at
    }
  end

  protected

  def get_application
    @application ||= ClientApplication.where(:app_id => params[:client_id]).first
  end

end
```

Finally, we can rewrite our API authenticate method appropriately and implement _current_user_. The latter can also tell us whether a user is an administrator or not.

```ruby
helpers do
  def warden
    env['warden']
  end
  def authenticated
    if warden.authenticated?
      return true
    elsif params[:access_token] and
        User.find_for_token_authentication("access_token" => params[:access_token])
      return true
    elsif params[:xapp_token] and
        AccessGrant.find_access(params[:xapp_token])
      return true
    else
      error!('401 Unauthorized', 401)
    end
  end
  def current_user
    warden.user || User.find_for_token_authentication("access_token" => params[:access_token])
  end
  def is_admin?
    current_user && current_user.is_admin?
  end
  # returns 401 if there's no current user
  def authenticated_user
    authenticated
    error!('401 Unauthorized', 401) unless current_user
  end
  # returns 401 if not authenticated as admin
  def authenticated_admin
    authenticated
    error!('401 Unauthorized', 401) unless is_admin?
  end
end
```

This is a little thick. Maybe someone can take a stab at sinking some of this into Grape as authentication middleware?
