#!/usr/bin/env ruby

require_relative "base"

CurrentUser.user = User.system

fix = ENV.fetch("FIX", "false").truthy?

Post.where(published_at: nil).where.not(pixiv_id: nil).find_each do |post|
  parsed_time = Source::URL.parse(post.source)&.parsed_date
  next if parsed_time.nil?
  puts ({ id: post.id, source: post.source, published_at: parsed_time }).to_json
  post.update!(published_at: parsed_time) if fix
rescue StandardError => e
  puts ({ id: post.id, source: post.source, error: e.message }).to_json
end

twitter_hosts = %w[
  twitter.com
  x.com
  fxtwitter.com
  vxtwitter.com
  twittpr.com
  fixvx.com
  fixupx.com
  nitter.net
  xcancel.com
  nitter.poast.org
]
twitter_hosts.each do |host|
  ["https", "http"].each do |protocol|
    prefix = "#{protocol}://#{host}*"
    Post.where(published_at: nil).where_ilike(:source, prefix).find_each do |post|
      parsed_time = Source::URL.parse(post.source)&.parsed_date
      next if parsed_time.nil?
      puts ({ id: post.id, source: post.source, published_at: parsed_time }).to_json
      post.update!(published_at: parsed_time) if fix
    rescue StandardError => e
      puts ({ id: post.id, source: post.source, error: e.message }).to_json
    end
  end
end
