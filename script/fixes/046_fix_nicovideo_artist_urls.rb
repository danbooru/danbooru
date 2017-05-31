#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.without_timeout do
  ArtistUrl.where("normalized_url like ?", "\%nico\%").find_each do |url|
    before = url.normalized_url
    url.normalize!
    puts "#{before} -> #{url.normalized_url}" if before != url.normalized_url
  end
end
