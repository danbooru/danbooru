module GoogleBigQuery
  class PostVersion < Base
    def find_removed(tag, limit = 1_000)
      tag = escape(tag)
      limit = limit.to_i
      query("select id, post_id, updated_at, updater_id, updater_ip_addr, tags, added_tags, removed_tags, parent_id, rating, source from [#{data_set}.post_versions] where regexp_match(removed_tags, \"(?:^| )#{tag}(?:$| )\") order by updated_at desc limit #{limit}")
    end

    def find_added(tag, limit = 1_000)
      tag = escape(tag)
      limit = limit.to_i
      query("select id, post_id, updated_at, updater_id, updater_ip_addr, tags, added_tags, removed_tags, parent_id, rating, source from [#{data_set}.post_versions] where regexp_match(added_tags, \"(?:^| )#{tag}(?:$| )\") order by updated_at desc limit #{limit}")
    end
  end
end
