---
layout: post
title: "Prompting for Github Credentials in Ruby"
date: "2018-08-23"
tags: [github]
---
Last week I [wrote a tool](/2018/08/15/finding-a-github-users-email-address.html) to find a Github user's e-mail address from their commits. One of the annoyances of the original implementation was the need to manually generate a personal Github access token and store it. However, I've seen other tools (eg. [ghi](https://github.com/stephencelis/ghi)) ask for credentials and store the token in the OSX keychain. How does one accomplish that? We're going to improve a bit upon ghi's code.

### Prompt for a Username and Password

Reading a username is fairly straightforward with `$stdin.gets.chomp`. We can improve a bit upon it and fetch it from `git config` instead.

{% highlight ruby %}
def username
  @username ||= begin
    username = `git config github.user`.chomp
    username = get_username if username.empty?
    username
  end
end

def get_username
  print 'Enter GithHub username: '
  $stdin.gets.chomp
rescue Interrupt => e
  raise e, 'ctrl + c'
end
{% endhighlight %}

We don't want to echo passwords.

{% highlight ruby %}
def password
  @password ||= get_password
end

def get_password
  print "Enter #{username}'s GitHub password (never stored): "
  get_secure
end

def get_secure
  current_tty = `stty -g`
  system 'stty raw -echo -icanon isig' if $CHILD_STATUS.success?
  input = ''
  while (char = $stdin.getbyte) && !((char == 13) || (char == 10))
    if (char == 127) || (char == 8)
      input[-1, 1] = '' unless input.empty?
    else
      $stdout.write '*'
      input << char.chr
    end
  end
  print "\r\n"
  input
rescue Interrupt => e
  raise e, 'ctrl + c'
ensure
  system "stty #{current_tty}" unless current_tty.empty?
end
{% endhighlight %}

Note how we [change stty](https://stackoverflow.com/questions/22832933/what-does-stty-raw-echo-do-on-os-x), support backspace, echo `*` and bail on Ctrl + C.

### Authenticate Against Github with 2FA

We can use [github_api](https://github.com/piotrmurach/github) to authenticate against Github with a username and password.

{% highlight ruby %}
Github.new do |config|
  config.basic_auth = [username, password].join(':')
end
{% endhighlight %}

However, most users now hopefully have two-factor authentication enabled. Github auth will fail with `Github::Error::Unauthorized` and return a `X-GitHub-OTP` header with the value of `required; app` to signal that a 2FA code is required. The latter will need to be sent back in the `X-GitHub-OTP` header.

{% highlight ruby %}
def github(code = nil)
  Github.new do |config|
    config.basic_auth = [username, password].join(':')
    if code
      config.connection_options = {
        headers: {
          'X-GitHub-OTP' => code
        }
      }
    end
  end
end
{% endhighlight %}

### Create a Github Token

To create a token we supply a note that uniquely identifies it on the Github personal tokens page. Once created tokens cannot be retrieved, so we will store the value locally. To uniquely identify tokens we include the local host name in the note.

{% highlight ruby %}
def note
  "MyApp on #{Socket.gethostname}"
end
{% endhighlight %}

We recurse with 2FA until a token can be successfully created with `auth.create` or an error occurs. One such interesting error is when trying to create a token that already exists. Since token values cannot be obtained after creation, we must tell the user to delete the token manually. And we don't want to delete the token automatically because it will possibly break another app instance that has created it.

{% highlight ruby %}
def get_code
  print 'Enter GitHub 2FA code: '
  get_secure
end

def github_token(code = nil)
  github(code).auth.create(scopes: ['public_repo'], note: note).token
rescue Github::Error::Unauthorized => e
  case e.response_headers['X-GitHub-OTP']
  when /required/ then
    github_token(get_code)
  else
    raise e
  end
rescue Github::Error::UnprocessableEntity => e
  raise e, 'A token already exists! Please revoke it from https://github.com/settings/tokens.'
end
{% endhighlight %}

### Storing in Keychain

We use the command-line `security add-internet-password` tool to store Internet passwords in Keychain and `security find-internet-password` to retrieve one.

{% highlight ruby %}
def store!(options)
  system security('add', options)
end

def get(options)
  system security('find', options)
end

def security(command = nil, options = nil)
  run = ['security']
  run << "#{command}-internet-password"
  run << "-a #{options[:username]}"
  run << "-s #{options[:server]}"
  if command == 'add'
    run << "-l #{options[:label]}"
    run << '-U'
    run << "-w #{options[:password]}" if options.key?(:password)
  else
    run << '-w'
  end
  run.join ' '
end
{% endhighlight %}

### Putting It Together

{% highlight bash %}
$ fue find defunkt

Enter dblock's GitHub password (never stored): ******************
Enter GitHub 2FA code: ******
Token saved to keychain.

Chris Wanstrath <chris@ozmm.org>
Chris Wanstrath <chris@github.com>
{% endhighlight %}

Running the tool the second time no longer prompts for credentials!

See [fue@6937a4](https://github.com/dblock/fue/commit/6937a4cca1e5916a8181620e62ef1e99f84f8187) for the rest of implementation details.
