#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  users = User.where("custom_style != ''").select { |user| !user.custom_css.valid? }

  users.each do |user|
    Dmail.create_automated(to: user, title: "Action required: Your custom CSS is invalid", body: <<~EOS)
      Hi,

      The custom CSS in your account settings is invalid and has been removed from your account. To restore it, go to https://codebeautify.org/cssvalidate, copy and paste the CSS below, and fix any errors that are shown. Then, go to your account settings at https://danbooru.donmai.us/settings, click the Advanced tab, and re-add your custom CSS.

      [code]
      #{user.custom_style}
      [/code]
    EOS

    user.update!(custom_style: "")
  end
end
