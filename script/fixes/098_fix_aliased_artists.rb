#!/usr/bin/env ruby

require_relative "base"

# Fix artist entries where the tag was aliased but the URLs weren't moved to
# the new artist entry.
with_confirmation do
  CurrentUser.scoped(User.system, "127.0.0.1") do
    aliased_artists = Artist.joins(:tag_alias).where.associated(:urls).distinct

    aliased_artists.each do |artist|
      next if artist.tag.category_name != "Artist"
      next if artist.tag_alias.consequent_tag.category_name != "Artist"

      old_name = artist.name
      new_name = artist.tag_alias.consequent_name

      artist.update_attribute(:is_deleted, false) # undelete first so the tag move works
      TagMover.new(old_name, new_name).move_artist!
      added_urls = (artist.urls - Artist.find_by_name(new_name).urls).map(&:url)

      puts({
        old_name: old_name,
        new_name: new_name,
        added_urls: added_urls,
      }.to_json)
    end
  end
end
