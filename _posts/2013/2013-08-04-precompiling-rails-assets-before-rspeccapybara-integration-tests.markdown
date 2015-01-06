---
layout: post
title: "Precompiling Rails Assets before RSpec/Capybara Integration Tests"
redirect_from: "/precompiling-rails-assets-before-rspeccapybara-integration-tests/"
date: 2013-08-04 16:41:01
tags: [rspec, capybara, rails, testing]
comments: true
dblog_post_id: 389
---
The first Capybara integration test always tends to timeout when compiling assets on-demand. It’s just damn too slow. Precompile your assets before the test is run.

```ruby
RSpec.configure do |config|
  config.before :all do
    ENV['PRECOMPILE_ASSETS'] ||= begin
      case self.class.metadata[:type]
      when :feature, :view
        STDOUT.write "Precompiling assets..."
        Sprockets::StaticCompiler.new(
          Rails.application.assets,
          File.join(Rails.public_path, Rails.configuration.assets.prefix),
          Rails.configuration.assets.precompile,
          manifest_path: Rails.configuration.assets.manifest,
          digest: Rails.configuration.assets.digest,
          manifest: false).compile
        STDOUT.puts " done."
        Time.now.to_s
      end
    end
  end
end
```
