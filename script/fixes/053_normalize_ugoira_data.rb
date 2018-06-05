#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

PixivUgoiraFrameData.where("data like ?", "\%delay_msec%").find_each do |fd|
  fd.normalize_data
  fd.save
end
