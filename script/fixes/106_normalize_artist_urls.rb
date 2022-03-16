#!/usr/bin/env ruby

require_relative "base"

CurrentUser.scoped(User.system, "127.0.0.1") do
  Artist.rewrite_urls('^http://www\.artstation\.com', %r{^http://www\.artstation\.com}, 'https://www.artstation.com')
  Artist.rewrite_urls('^http://www\.artstation\.com', %r{^-http://www\.artstation\.com}, '-https://www.artstation.com')
  Artist.rewrite_urls('^https://www\.artstation\.com/artist', %r{https://www\.artstation\.com/artist/([a-zA-Z0-9_.-]+)/?$}, 'https://www.artstation.com/\1')
  Artist.rewrite_urls('^https?://[^.]+\.artstation\.com/?$', %r{https?://([a-zA-Z0-9_.-]+)\.artstation\.com/?$}, 'https://www.artstation.com/\1')

  Artist.rewrite_urls('^https?://[^.]+\.deviantart\.com/?$', %r{https?://([a-zA-Z0-9_.-]+)\.deviantart\.com/?$}, 'https://www.deviantart.com/\1')

  Artist.rewrite_urls('^https?://[^.]+\.fanbox\.cc/?$', %r{https?://([^.]+)\.fanbox\.cc/?$}, 'https://\1.fanbox.cc')

  Artist.rewrite_urls('^http://fantia\.jp', %r{^http://fantia\.jp}, 'https://fantia.jp')
  Artist.rewrite_urls('^http://fantia\.jp', %r{^-http://fantia\.jp}, '-https://fantia.jp')

  Artist.rewrite_urls('^https?://[^.]+\.lofter\.com/?$', %r{https?://([^.]+)\.lofter\.com/?$}, 'https://\1.lofter.com')

  Artist.rewrite_urls('^http://pawoo\.net', %r{^http://pawoo\.net}, 'https://pawoo.net')
  Artist.rewrite_urls('^http://pawoo\.net', %r{^-http://pawoo\.net}, '-https://pawoo.net')
end
