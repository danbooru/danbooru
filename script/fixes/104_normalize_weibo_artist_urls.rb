#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  # https://m.weibo.cn/u/7119279079 -> https://m.weibo.com/u/7119279079
  Artist.rewrite_urls('weibo\.cn', /weibo\.cn/, "weibo.com")

  # https://m.weibo.com/u/7119279079 -> https://www.weibo.com/u/7119279079
  Artist.rewrite_urls('m\.weibo\.com', /m\.weibo\.com/, "www.weibo.com")

  # https://weibo.com/u/5466604405 -> https://www.weibo.com/u/5466604405
  Artist.rewrite_urls('https?://weibo\.com', %r{https?://weibo\.com}, "https://www.weibo.com")

  # https://www.weibo.com/5493194708/profile?rightmod=1&wvr=6&mod=personnumber&is_all=1 -> https://www.weibo.com/5493194708/profile
  Artist.rewrite_urls('weibo\.com.*\?.*', /(.*weibo\.com.*)(\?.*$)/, '\1')

  # https://www.weibo.com/5493194708/profile -> https://www.weibo.com/5493194708
  Artist.rewrite_urls('weibo.com/[0-9]+/profile', %r{/profile$}, "")

  # https://www.weibo.com/5493194708/home -> https://www.weibo.com/5493194708
  Artist.rewrite_urls('weibo.com/[0-9]+/home', %r{/home$}, "")
end
