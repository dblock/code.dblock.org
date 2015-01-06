---
layout: post
title: "TaxCloud: SOAP Service Integration in Ruby"
redirect_from: "/taxcloud-soap-service-integration-in-ruby"
date: 2012-11-27 05:54:16
tags: [ruby, open source, testing]
comments: true
---
![]({{ site.url }}/images/posts/2012/2012-11-27-taxcloud-soap-service-integration-in-ruby/image_3.jpg)

I’ve been working on the the [tax_cloud](https://github.com/drewtempelmeyer/tax_cloud) gem for the past couple of days and am happy to announce version 0.2.0, released today. The gem was started by [@tempelmeyer](https://twitter.com/tempelmeyer/) and is now a mature wrapper for the [TaxCloud US Sales Tax calculation service](https://taxcloud.net/default.aspx).

This library is also a nice example of a generic SOAP client wrapper in Ruby. I wanted to point out several successful patterns for this integration, which I cannot take credit for, for the most part.

#### Error Handling

I borrowed error handling from [@modetojoy](https://twitter.com/modetojoy)’s Mongoid. Today someone said: "I had a bug in a spec and Durran told me how to fix it in an error message." True story. To accomplish this we define a base error that holds the problem, summary and resolution. In tax_cloud’s case this is  [TaxCloud::Errors::TaxCloudError](https://github.com/drewtempelmeyer/tax_cloud/blob/master/lib/tax_cloud/errors/tax_cloud_error.rb) paired with [config/locales/en.yml](https://github.com/drewtempelmeyer/tax_cloud/blob/master/lib/config/locales/en.yml), a locale file that does the error formatting. There’re two things to do in order for the error code to find the message: add the locale file to the load path, in [tax_cloud.rb](https://github.com/drewtempelmeyer/tax_cloud/blob/master/lib/tax_cloud.rb), and do a bit of formatting with I18n.

```ruby
I18n.load_path << File.join(File.dirname(__FILE__), "config", "locales", "en.yml")

def translate(key, options)
    ::I18n.translate("#{BASE_KEY}.#{key}", { :locale => :en }.merge(options)).strip
end
```

What does an error in tax_cloud look like?

```
Problem:
  Missing configuration.
Summary:
  TaxCloud requires an API login ID and key.
Resolution:
  Create a TaxCloud merchant account at http://www.taxcloud.net.
  Add a website to your TaxCloud account.
  This will generate an API ID and API Key that you will need to use the service.
  Configure the TaxCloud gem. For example, add the following to `config/initializers/tax_cloud.rb`.

  TaxCloud.configure do |config|
   config.api_login_id = 'your_tax_cloud_api_login_id'
   config.api_key = 'your_tax_cloud_api_key'
   config.usps_username = 'your_usps_username' # optional
  end
```

Pretty awesome.

#### Safe SOAP Requests

The tax_cloud gem uses [Savon](https://github.com/savonrb/savon) to make SOAP requests. "Savon" is French for "Soap", which confuses the French speakers like myself trying to explain that SOAP is Savon. Anyway, a client is initialized with its WSDL.

```ruby
module TaxCloud #:nodoc:
  class Client < Savon::Client
    def initialize
      super 'https://api.taxcloud.net/1.0/?wsdl'
    end
  end
end
```

First, we need to add authentication to every request, which is required by the API. We can override _request_.

```ruby
def request(method, body = {})
  super method, :body => body.merge(auth_params)
end

def auth_params
  {
    'apiLoginID' => TaxCloud.configuration.api_login_id,
    'apiKey' => TaxCloud.configuration.api_key
  }
end
```

Second, we want to handle SOAP errors, and give a detailed explanation for SOAP faults, Mongoid-style. This is your typical block with _yield_.

```ruby
def request(method, body = {})
  safe do
    super method, :body => body.merge(auth_params)
  end
end

def safe(&block)
  begin
    yield
  rescue Savon::SOAP::Fault => e
    raise TaxCloud::Errors::SoapError.new(e)
  end
end
```

The complete code can be found in [client.rb](https://github.com/drewtempelmeyer/tax_cloud/blob/master/lib/tax_cloud/client.rb). The error itself is parsed in [soap_error.rb](https://github.com/drewtempelmeyer/tax_cloud/blob/master/lib/tax_cloud/errors/soap_error.rb) – SOAP faults come in standard format.

#### Parsing Responses

We will now raise a good-looking exception on SOAP failures, but we still must protect ourselves from unexpected data or successful SOAP requests that return API errors. That possibility is the thing I detest most about SOAP (vs. REST) – it makes programming a client unnecessarily complicated. The TaxCloud service returns a SOAP body with different values in _key_response/key_result/response_type_, where the key will be the name of the method invoked (eg. _ping_response_). A bit of meta-programming can make a [base class](https://github.com/drewtempelmeyer/tax_cloud/blob/master/lib/tax_cloud/responses/base.rb), which can parse a response and match an XML path, raising errors where appropriate. It can be subclassed into a [generic response type](https://github.com/drewtempelmeyer/tax_cloud/blob/master/lib/tax_cloud/responses/generic.rb) and, finally, into specific declarative implementations such as [ping](https://github.com/drewtempelmeyer/tax_cloud/blob/master/lib/tax_cloud/responses/ping.rb) or [authorized](https://github.com/drewtempelmeyer/tax_cloud/blob/master/lib/tax_cloud/responses/authorized.rb).

Most services have a common response pattern, generalizing it yields a very productive framework where adding support for new calls requires very little to no code. And you must never, ever expose to the user that you’re making SOAP requests and return any kind of raw SOAP object. Return domain-specific classes with attributes on success and raise exceptions otherwise.

#### Testing SOAP Requests

The tax_cloud gem uses [VCR](https://github.com/myronmarston/vcr) to test SOAP requests. It’s surprisingly easy: use a cassette (a YAML file), which records it the first time you make a request. Second time around the file contents are used and no HTTP requests are made. You can filter out sensitive keys in the configuration.

```ruby
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('api-login-id')  { TaxCloud.configuration.api_login_id }
  c.filter_sensitive_data('api-key')       { TaxCloud.configuration.api_key }
  c.filter_sensitive_data('usps-username') { TaxCloud.configuration.usps_username }
end

def test_ping_with_invalid_credentials
  assert_raise TaxCloud::Errors::ApiError do
   VCR.use_cassette('ping_with_invalid_credentials') do
    TaxCloud.client.ping
   end
  end
end

def test_ping_with_invalid_response
  e = assert_raise TaxCloud::Errors::UnexpectedSoapResponse do
   VCR.use_cassette('ping_with_invalid_response') do
    TaxCloud.client.ping
   end
  end
  assert_equal "Expected a value for `ping_result`.", e.problem
end

def test_ping
  VCR.use_cassette('ping') do
   response = TaxCloud.client.ping
   assert_equal "OK", response
  end
end
```

You can see the rest of the tests [here](https://github.com/drewtempelmeyer/tax_cloud/tree/master/test).

#### Finally

Let me know if you use some of these ideas, post your comments and suggestions and please help improve the tax_cloud gem [on Github](https://github.com/drewtempelmeyer/tax_cloud).
