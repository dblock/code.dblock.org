---
layout: post
title: "Being Helpful with Ruby Exceptions and Error Messages"
redirect_from: "/being-helpful-with-ruby-exceptions-and-error-messages/"
date: 2013-05-15 01:57:17
tags: [ruby, open source]
comments: true
---
We talk a lot about error handling in Ruby. But we rarely talk about raising errors and creating helpful error messages that are actionable. A good error should tell the developer what went wrong and what to do about it.

One library is known for its excellent error messages. Consider a typical validation error from [Mongoid](https://github.com/mongoid/mongoid).

```
#<Mongoid::Errors::Validations:
  Problem:
   Validation of User failed.
  Summary:
   The following errors were found: Password can't be blank
  Resolution:
   Try persisting the document with valid data or remove the validations.>
```

This error describes the problem, offers a detailed summary and provides a possible resolution!

Let's implement a similar system for the [ruby-enum gem](https://github.com/dblock/ruby-enum/) that I [live-coded at NYC.rb](http://code.dblock.org/your-first-ruby-gem).

First, add a dependency on [i18n](http://rubygems.org/gems/i18n) and _require "i18n"_. Then, create a _lib/config/locales_ folder and an _en.yml_ file in it. English error messages will go there. This file will need to be loaded by our library, specifically in [ruby-enum.rb](https://github.com/dblock/ruby-enum/blob/master/lib/ruby-enum.rb).

```ruby
require 'i18n'
I18n.load_path << File.join(File.dirname(__FILE__), "config", "locales", "en.yml")
```

Error descriptions inside _en.yml_ contain the problem, summary and resolution. The YAML format supports multi-lines with `\_\_` and can include values from parameters using the `%{name}` syntax.

```yaml
en:
 ruby:
   enum:
     errors:
       messages:
         uninitialized_constant:
           message: "Uninitialized constant."
           summary: "The constant %{name}::%{key} has not been defined."
           resolution: "The enumerated value could not be found in class %{name}.\n
           \_Use 'define' to declare it.\n
           \_Example:\n
           \_\_module %{name}\n
           \_\_\_include Ruby::Enum\n
           \_\_\_define %{key}, 'value'\n
           \_\_end"
```

The base error class, [Ruby::Enum::Errors::Base](https://github.com/dblock/ruby-enum/blob/master/lib/ruby-enum/errors/base.rb) takes care of the translation. I stripped the implementation details below – the important parts is the _BASE_KEY_ value for localized error messages and the _compose_message_ method. Get the full implementation [here](https://github.com/dblock/ruby-enum/blob/master/lib/ruby-enum/errors/base.rb) and modify it for your project.

```ruby
module Ruby
 module Enum
   module Errors
     class Base < StandardError

       attr_reader :problem, :summary, :resolution

       def compose_message(key, attributes = {})
         @problem = create_problem(key, attributes)
         @summary = create_summary(key, attributes)
         @resolution = create_resolution(key, attributes)

         "\nProblem:\n  #{@problem}" +
         "\nSummary:\n  #{@summary}" +
         "\nResolution:\n  #{@resolution}"
       end

       private

         BASE_KEY = "ruby.enum.errors.messages" #:nodoc:

         # implementation of create_problem, summary and resolution

     end
   end
 end
end
```

Specific errors derive from this class.

```ruby
module Ruby
 module Enum
   module Errors
     class UninitializedConstantError < Base
       def initialize(attrs)
         super(compose_message("uninitialized_constant", attrs))
       end
     end
   end
 end
end
```

When raising an `UninitializedConstantError`, pass the values of _key_ and _name_ used in the en.yml file above.

```ruby
raise Ruby::Enum::Errors::UninitializedConstantError.new({
 :name => "Class",
 :key => "CONSTANT"
})
```

Here’s the result.

```
1.9.3-p362 :002 > require 'ruby-enum'
=> true
1.9.3-p362 :003 > raise Ruby::Enum::Errors::UninitializedConstantError.new({
:name => "Class",
:key => "CONSTANT"
})

Ruby::Enum::Errors::UninitializedConstantError:
Problem:
 Uninitialized constant.
Summary:
 The constant Class::CONSTANT has not been defined.
Resolution:
 The enumerated value could not be found in class Class.
 Use 'define' to declare it.
 Example:
  module Class
   include Ruby::Enum
   define CONSTANT, 'value'
  end
```

Beautiful.
