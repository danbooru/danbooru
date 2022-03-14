#!/usr/bin/env ruby

require_relative "base"

CurrentUser.scoped(User.system, "127.0.0.1") do
  Artist.joins(:urls).where_regex("artist_urls.url", '^https?://www.pixiv.net/member\.php\?id=[0-9]+$').find_each do |artist|
    artist.update!(url_string: artist.url_string.gsub(%r{https?://www\.pixiv\.net/member\.php\?id=([0-9]+)$}, 'https://www.pixiv.net/users/\1'))
    puts artist.id
  end

  Artist.joins(:urls).where_regex("artist_urls.url", '^https?://www.pixiv.net/en/users/[0-9]+$').find_each do |artist|
    artist.update!(url_string: artist.url_string.gsub(%r{https?://www\.pixiv\.net/en/users/([0-9]+)$}, 'https://www.pixiv.net/users/\1'))
    puts artist.id
  end
end
