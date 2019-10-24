#!/usr/bin/env ruby

require_relative "../../config/environment"

# WikiPage.find_each do |wiki_page|
#   wiki_page.update_dtext_links
#   wiki_page.save!(touch: false, validate: false)
# end

def reindex
  WikiPage.find_in_batches(batch_size: 500) do |wiki_pages|
    WikiPage.transaction do
      wiki_pages.each do |wiki_page|
        DtextLink.new_from_dtext(wiki_page.body).each do |link|
          link.model = wiki_page
          link.save!(touch: false, validate: false)
        end
      end
    end
  end
end

reindex
