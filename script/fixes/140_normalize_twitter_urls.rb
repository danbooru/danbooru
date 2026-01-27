#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  Artist.rewrite_urls('^https://twitter\.com/intent/user?user_id=\d+', %r{^https://twitter\.com/intent/user?user_id=(\d+)}, 'https://x.com/i/user/\1')
  Artist.rewrite_urls('^https://twitter\.com/intent/user?user_id=\d+', %r{^-https://twitter\.com/intent/user?user_id=(\d+)}, '-https://x.com/i/user/\1')
  Artist.rewrite_urls('^https://twitter\.com/', %r{^https://twitter\.com}, "https://x.com")
  Artist.rewrite_urls('^https://twitter\.com/', %r{^-https://twitter\.com}, "-https://x.com")
end
