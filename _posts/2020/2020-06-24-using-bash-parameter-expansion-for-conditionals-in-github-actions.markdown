---
layout: post
title: "Using Bash Parameter Expansion for Conditionals in GitHub Actions"
date: 2020-06-24
tags: [github]
comments: true
---
I am late to using GitHub Actions for CI, and immediately ran into an issue trying to figure out how to conditionally install a different version of Bundler for a certain version of Rails in [radar/distance_of_time_in_words#104](https://github.com/radar/distance_of_time_in_words/pull/104). Bundler 2.x doesn't work with Rails 4, and needs to be downgraded.

{% highlight bash %}
Fetching gem metadata from http://rubygems.org/.............
Fetching gem metadata from http://rubygems.org/.
Resolving dependencies...
Bundler could not find compatible versions for gem "bundler":
  In rails_4.gemfile:
    bundler

    rails (~> 4.0) was resolved to 4.2.11.3, which depends on
      bundler (>= 1.3.0, < 2.0)

  Current Bundler version:
    bundler (2.1.4)

{% endhighlight %}

I decided to use default Bundler as much as possible, and run `gem install bundler -v 1.17.3` for a certain version of Rails.

### Use `if:`

My first solution was to use an `if:` step.

{% highlight yaml %}
{% raw %}
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        include:
          - ruby-version: 2.6.x
          - ruby-version: 2.4.x
            bundler-version: 1.17.3
            gemfile: gemfiles/rails_4.gemfile
    steps:
      - uses: actions/checkout@v2
      - name: Set up Ruby
        uses: actions/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby-version }}
      - name: Install Bundler
        if: ${{ matrix.bundler-version }}
        run: |
          gem uninstall bundler
          gem install bundler -v ${{ matrix.bundler-version }}
      - name: Build and test
        env:
          BUNDLE_GEMFILE: ${{ matrix.gemfile }}
        run: |
          bundle install
          bundle exec rake
{% endraw %}
{% endhighlight %}

This worked because `bundler` was installed by default.

### Use another `if:`

Using `if:` to install a non-default version of Bundler will suddenly break when some future run uses a newer, default, version of Bundler that breaks everything. We can craft another `if:` to install a specific version or, for now, display the default version of Bundler.

{% highlight yaml %}
{% raw %}
      - name: Use Default Bundler
        if: ${{ !matrix.bundler-version }}
        run: |
          bundler --version
      - name: Install Custom Bundler
        if: ${{ matrix.bundler-version }}
        run: |
          gem uninstall bundler
          gem install bundler -v ${{ matrix.bundler-version }}
{% endraw %}
{% endhighlight %}

This [worked](https://github.com/dblock/distance_of_time_in_words/pull/1/checks?check_run_id=803594427) using the negation operator `!`. I do find the lack of `else:` regrettable.

### Use Bash Parameter Expansion

My final and favorite solution is to use [bash parameter expansion](https://wiki.bash-hackers.org/syntax/pe). In Bash you can write `${BUNDLER:-2.1.4}` which uses the value of `$BUNDLER` when available, and `2.1.4` otherwise.

{% highlight yaml %}
{% raw %}
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        include:
          - ruby-version: 2.4.x
          - ruby-version: 2.4.x
            bundler-version: 1.17.3
            gemfile: gemfiles/rails_4.gemfile
    steps:
      - uses: actions/checkout@v2
      - name: Set up Ruby
        uses: actions/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby-version }}
      - name: Build and test
        env:
          BUNDLE_GEMFILE: ${{ matrix.gemfile }}
          BUNDLER: ${{ matrix.bundler-version }}
        run: |
          gem uninstall bundler
          gem install bundler -v ${BUNDLER:-2.1.4}
          bundle install --jobs 4 --retry 3
          bundle exec rake
{% endraw %}
{% endhighlight %}

I find this pattern quite elegant. To summarize.

1. Set a variable in `matrix`, e.g. `bundler-version: 1.17.3`.
1. Assign it to an environment variable via `env`, e.g. `BUNDLER: ${{ matrix.bundler-version }}`.
1. Use it with a default value in `run`, e.g. `gem install bundler -v ${BUNDLER:-2.1.4}`.

See [radar/distance_of_time_in_words#104](https://github.com/radar/distance_of_time_in_words/pull/104) for more details.
