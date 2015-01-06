---
layout: post
title: "Exporting Data to Excel in Ruby on Rails w/ Spreadsheet and to_xls"
redirect_from: "/exporting-data-to-excel-in-ruby-on-rails-w-spreadsheet-and-toxls"
date: 2011-09-01 23:32:35
tags: [excel, rails, ruby]
comments: true
---
![]({{ site.url }}/images/posts/2011/2011-09-01-exporting-data-to-excel-in-ruby-on-rails-w-spreadsheet-and-toxls/image_7.jpg)

We’re going to export data to Excel from our RoR application, in about five lines of code. There’re many options available out there and it’s all pretty confusing. People try to export CSV and XML formats.

Here’s how we do it, and so should you.

#### Just Do It!

Use [spreadsheet 0.6.5.8](https://rubygems.org/gems/spreadsheet) with [this monkey-patch](https://gist.github.com/1187549) added as _initializers/spreadsheet_encodings.rb_ and [to_xls 1.0](https://rubygems.org/gems/to_xls) from my [to-xls-on-models branch](https://github.com/dblock/to_xls/tree/to-xls-on-models).

```ruby
gem "spreadsheet", "0.6.5.8"
gem "to_xls", :git => "https://github.com/dblock/to_xls.git", :branch => "to-xls-on-models"
```

Register the Excel MIME type in _config/initializers/mime_types.rb_.

```ruby
Mime::Type.register "application/vnd.ms-excel", :xls
```

Add a _as_xls_ method to any model that you want to export that contains the fields of interest. Here’s what I added to _app/models/user.rb_.

```ruby
def as_xls(options = {})
  {
      "Id" => id.to_s,
      "Name" => name,
      "E-Mail" => email,
      "Joined" => created_at,
      "Last Signed In" => last_sign_in_at,
      "Sign In Count" => sign_in_count
  }
end
```

You can also simply call _as_json_ inside _as_xls_. Note that currently only top-level keys are exported.

Add support for the .XLS format in any controller out of which you want to export Excel files. Here’s what I added to _app/controllers/users_controller.rb_.

```ruby
def index
  @users = User.all
  respond_to do |format|
    format.html
    format.xls { send_data @users.to_xls, content_type: 'application/vnd.ms-excel', filename: 'users.xls' }
  end
end
```

Add a link on the users view. Here’s what I added to _app/views/users.html.haml_. The parameter merging lets you reuse whatever parameters were passed in the page.

```ruby
= link_to 'Export', users_path(request.parameters.merge({:format => :xls}))
```

We added some styles, so here’s what the export button looks like next to another one.

![]({{ site.url }}/images/posts/2011/2011-09-01-exporting-data-to-excel-in-ruby-on-rails-w-spreadsheet-and-toxls/image_17.jpg)

You get real XLS documents, book & al.

We can write a spec for this controller too.

```ruby
describe "GET index.xls" do
  it "creates an Excel spreadsheet with all users" do
    user = Fabricate :user
    get :index, :format => :xls
    response.headers['Content-Type'].should == "application/vnd.ms-excel"
    s = Spreadsheet.open(StringIO.new(response.body))
    s.worksheets.count.should == 1
    w = s.worksheet(0)
    w.should_not be_nil
    w.row(0)[0].should == "Id"
    w.row(1)[0].should == user.id.to_s
    w.row(0)[1].should == "Name"
    w.row(1)[1].should == user.name
  end
end
```

#### Links

- [spreadsheet gem home](http://spreadsheet.ch/), [rubygems](https://rubygems.org/gems/spreadsheet) and [patch for frozen hash in encoding](http://groups.google.com/group/rubyspreadsheet/browse_frm/thread/29debd680f45fd6)
- [to_xls home](http://github.com/splendeo/to_xls) and [rubygems](https://rubygems.org/gems/to_xls) and [my pull request to to_xls with as_xls support](https://github.com/splendeo/to_xls/pull/2)
- [plataforma’s blog post](http://blog.plataformatec.com.br/2009/09/exporting-data-to-csv-and-excel-in-your-rails-app/) on the topic that helped me steer in the right direction
- [spreadsheet_encodings.rb monkey patch](https://gist.github.com/1187549)
- original [to_csv](https://github.com/arydjmal/to_csv) that inspired to_xls
- [an alternative using rxsl templates](https://github.com/10to1/spreadsheet_on_rails)
