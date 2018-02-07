module GoogleBigQuery
  class PostVersion < Base
    def find_removed(tag, limit = 1_000)
      limit = limit.to_i
      query("select id, post_id, updated_at, updater_id, updater_ip_addr, tags, added_tags, removed_tags, parent_id, rating, source from [#{data_set}.post_versions] where #{remove_tag_condition(tag)} order by updated_at desc limit #{limit}")
    end

    def find_added(tag, limit = 1_000)
      limit = limit.to_i
      query("select id, post_id, updated_at, updater_id, updater_ip_addr, tags, added_tags, removed_tags, parent_id, rating, source from [#{data_set}.post_versions] where #{add_tag_condition(tag)} order by updated_at desc limit #{limit}")
    end

    def add_tag_condition(t)
      es = escape(t)
      "regexp_match(added_tags, \"(?:^| )#{es}(?:$| )\")"
    end

    def remove_tag_condition(t)
      es = escape(t)
      "regexp_match(removed_tags, \"(?:^| )#{es}(?:$| )\")"
    end

    def find(user_id, added_tags, removed_tags, min_version_id, max_version_id, limit = 1_000)
      constraints = []

      constraints << "updater_id = #{user_id.to_i}"

      if added_tags
        added_tags.scan(/\S+/).each do |tag|
          constraints << add_tag_condition(tag)
        end
      end

      if removed_tags
        removed_tags.scan(/\S+/).each do |tag|
          constraints << remove_tag_condition(tag)
        end
      end

      if min_version_id
        constraints << "id >= #{min_version_id.to_i}"
      end

      if max_version_id
        constraints << "id <= #{max_version_id.to_i}"
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
