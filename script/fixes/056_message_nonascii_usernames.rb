#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

User.where("name !~ ?", "^[ -~]*$").find_each do |user|
  Dmail.create_automated(
    :to_id => user.id,
    :title => "Name change required",
    :body => "Because of issues with users exploiting various Unicode characters in their name, in the future all non-ASCII characters and any non-printable characters will be forbidden. This means you will have to change your name. You can visit \"this page\":/user_name_change_requests/new to change your name. You will have 30 days to change your name or else your account will be banned."
  )
end
