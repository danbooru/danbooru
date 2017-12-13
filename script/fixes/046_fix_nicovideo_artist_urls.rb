#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ArtistUrl.without_timeout do
  ArtistUrl.where("normalized_url like ?", "\%nicovideo\%").find_each do |url|
    before = url.normalized_url
    url.normalize
    puts "#{before} -> #{url.normalized_url}" if before != url.normalized_url unless ArtistUrl.where(normalized_url: url.normalized_url).exists?
  end
end
