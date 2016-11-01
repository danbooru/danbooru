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

    def find(user_id, added_tags, removed_tags, limit = 1_000)
      constraints = []

      constraints << "updater_id = #{user_id.to_i}"

      if added_tags
        added_tags.scan(/\S+/).each do |tag|
          escaped = escape(tag)
          constraints << "regexp_match(added_tags, \"(?:^| )#{escaped}(?:$| )\")"
        end
      end

      if removed_tags
        removed_tags.scan(/\S+/).each do |tag|
          escaped = escape(tag)
          constraints << "not regexp_match(added_tags, \"(?:^| )#{escaped}(?:$| )\")"
        end
      end

      limit = limit.to_i
      sql = "select id from [#{data_set}.post_versions] where " + constraints.join(" and ") + " order by updated_at desc limit #{limit}"
      result = query(sql)

      if result["rows"]
        result["rows"].map {|x| x["f"][0]["v"].to_i}
      else
        []
      end
    end
  end
end
