---
layout: post
title: "Capybara: Failed to Resynchronize, Ajax Request Timed Out (not caused by green elves)"
redirect_from: "/capybara-failed-to-resynchronize-ajax-request-timed-out/"
date: 2011-09-28 13:17:36
tags: [capybara, rails, ruby, testing]
comments: true
---
I used to attribute this error to little green elves inside of Capybara, Selenium or Firefox. But, as usual, things turn out to have a much more reasonable explanation.

```
1) When user uploads an image
    Failure/Error: attach_file('Drop here', File.join(Rails.root, "/spec/assets/pic.jpg"))
    failed to resynchronize, ajax request timed out
    # (eval):2:in `attach_file'
    # ./spec/acceptance/upload_image_spec.rb:15:in `block (3 levels) in <top (required)>'
```

The spec code is as follows.

```ruby
context "capybara", :driver => :selenium do
  it "should upload and save a pic" do
    visit '/upload/'
    wait_until { find('#upload', visible: true) }
    attach_file('Drop here', File.join(Rails.root, "/spec/assets/pic.jpg"))
    wait_until { find('.edit_pic', visible: true) }
  end
end
```

The upload generates an `.edit_pic` block at the end of the page. But what happens if the browser height is not big enough to display it? Capybara just waits for the element to become visible and eventually gives up with this error. My first fix was to add `page.execute_script("window.scrollTo(0, document.body.scrollHeight);")`, but that’s not even necessary because Capybara will patiently wait for the file to finish uploading in that _attach_file_ line. It’s good like that.
