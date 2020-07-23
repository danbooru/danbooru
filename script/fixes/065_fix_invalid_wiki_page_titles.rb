#!/usr/bin/env ruby

require_relative "../../config/environment"

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

# Fix wiki page titles containing invalid space characters.
WikiPage.transaction do
  WikiPage.where("title ~ '\\s'").find_each do |wiki_page|
    wiki_page.normalize_title
    wiki_page.save!
  # handle name conflicts
  rescue ActiveRecord::RecordInvalid
    wiki_page.normalize_title
    wiki_page.title = "#{wiki_page.title}_#{wiki_page.id}"
    wiki_page.save!
  ensure
    puts "wiki id=#{wiki_page.id} title=#{wiki_page.title}"
  end
end
