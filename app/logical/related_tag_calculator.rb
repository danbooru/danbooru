class RelatedTagCalculator
  def self.find_tags(tag, limit)
    Post.with_timeout(5_000, []) do
      Post.tag_match(tag).limit(limit).select("posts.tag_string").reorder("posts.md5").map(&:tag_string)
    end
  end

  def self.calculate_from_sample_to_array(tags, category_constraint = nil)
    convert_hash_to_array(calculate_from_sample(tags, Danbooru.config.post_sample_size, category_constraint))
  end

  def self.calculate_from_sample(tags, limit, category_constraint = nil)
    counts = Hash.new {|h, k| h[k] = 0}

    find_tags(tags, limit).each do |tags|
      tag_array = Tag.scan_tags(tags)
      if category_constraint
        tag_array.each do |tag|
          category = Tag.category_for(tag)
          if category == category_constraint
            counts[tag] += 1
          end
        end
      else
        tag_array.each do |tag|
          counts[tag] += 1
        end
      end
    end

    counts
  end

  def self.convert_hash_to_array(hash)
    hash.to_a.sort_by {|x| -x[1]}.slice(0, 25)
  end

  def self.convert_hash_to_string(hash)
    convert_hash_to_array(hash).flatten.join(" ")
  end
end
