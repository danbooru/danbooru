#!/usr/bin/env ruby

require_relative "base"

fix = ENV.fetch("FIX", "false").truthy?

def update_links(model, dtext)
  dtext_links = DtextLink.new_from_dtext(dtext)

  old_links = model.dtext_links.pluck(:link_type, :link_target).to_set
  new_links = dtext_links.pluck(:link_type, :link_target).to_set
  added = new_links - old_links
  removed = old_links - new_links

  if old_links != new_links
    model.update_dtext_links
  end

  [added, removed]
end

WikiPage.find_each do |wiki_page|
  wiki_page.with_lock do
    added, removed = update_links(wiki_page, wiki_page.dtext_body)

    puts ({ id: wiki_page.id, wiki: wiki_page.title, added:, removed: }).compact_blank.to_json
  end
end

ForumPost.find_each do |forum_post|
  forum_post.with_lock do
    added, removed = update_links(forum_post, forum_post.dtext_body)

    puts ({ id: forum_post.id, added:, removed: }).compact_blank.to_json
  end
end

Pool.find_each do |pool|
  pool.with_lock do
    added, removed = update_links(pool, pool.dtext_description)

    puts ({ id: pool.id, title: pool.name, added:, removed: }).compact_blank.to_json
  end
end
