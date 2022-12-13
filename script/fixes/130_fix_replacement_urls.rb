#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  fix = ENV.fetch("FIX", "false").truthy?

  PostReplacement.where_regex(:replacement_url, "(^ )|( $)").find_each do |replacement|
    replacement.replacement_url = replacement.replacement_url.strip

    replacement.save!(touch: false) if fix
    puts ({ id: replacement.id, changes: replacement.changes }).to_json
  end
end
