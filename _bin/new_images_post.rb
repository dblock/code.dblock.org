images_path = File.expand_path ARGV[0]
raise "#{images_path} does not exist" unless Dir.exist?(images_path)

# create a new markdown file
post_name = File.basename(ARGV[0])
post_parts = post_name.match(/([\d-]*)\-(.*)/)
post_date, post_title = post_parts[1], post_parts[2]

post_filename = "#{Dir.pwd}/_posts/#{post_name}.markdown"
fail "#{post_filename} exists!" if File.exist? post_filename

File.open post_filename, "w" do |file|
  file.write <<-EOS
---
layout: post
title: "#{post_title}"
date: #{post_date}
tags: []
comments: true
---
  EOS

  Dir["#{images_path}/*"].each do |filename|
    file.write "![]({{ site.url }}/images/posts/#{Time.now.year}/#{post_name}/#{File.basename(filename)})\n\n"
  end
end
