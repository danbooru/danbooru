#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

Tag.find_each do |tag|
  next if tag.name.ascii_only?
  mb_name = tag.name.mb_chars
  if mb_name.downcase != mb_name
    if Tag.where("name = ?", mb_name.downcase).exists?
      tag.destroy
    else
      tag.update_column(:name, mb_name.downcase.to_s)
    end
  end
end

Artist.find_each do |artist|
  next if artist.name.ascii_only?
  mb_name = artist.name.mb_chars
  if mb_name.downcase != mb_name
    artist.save # name will be normalized automatically
  end
end
