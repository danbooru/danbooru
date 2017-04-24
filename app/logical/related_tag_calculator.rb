class RelatedTagCalculator
  def self.find_tags(tag, limit)
    CurrentUser.without_safe_mode do
      Post.with_timeout(5_000, [], {:tags => tag}) do
        Post.tag_match(tag).limit(limit).reorder("posts.md5").pluck(:tag_string)
      end
    end
  end

  def self.calculate_from_sample_to_array(tags, category_constraint = nil)
    convert_hash_to_array(calculate_from_sample(tags, Danbooru.config.post_sample_size, category_constraint))
  end

  def self.calculate_from_posts_to_array(posts)
    convert_hash_to_array(calculate_from_posts(posts))
  end

  def self.calculate_from_posts(posts)
    counts = Hash.new {|h, k| h[k] = 0}

    posts.flat_map(&:tag_array).each do |tag|
      counts[tag] += 1
    end

    counts
  end

  def self.calculate_similar_from_sample(tag)
    # this uses cosine similarity to produce more useful
    # related tags, but is more db intensive
    counts = Hash.new {|h, k| h[k] = 0}

    CurrentUser.without_safe_mode do
      Post.with_timeout(5_000, [], {:tags => tag}) do
        Post.tag_match(tag).limit(400).reorder("posts.md5").pluck(:tag_string).each do |tag_string|
          tag_string.scan(/\S+/).each do |tag|
            counts[tag] += 1
          end
        end
      end
    end

    tag_record = Tag.find_by_name(tag)
    candidates = convert_hash_to_array(counts, 100)
    similar_counts = Hash.new {|h, k| h[k] = 0}
    CurrentUser.without_safe_mode do
      PostReadOnly.with_timeout(5_000, nil, {:tags => tag}) do
        candidates.each do |ctag, _|
          acount = PostReadOnly.tag_match("#{tag} #{ctag}").count
          ctag_record = Tag.find_by_name(ctag)
          div = Math.sqrt(tag_record.post_count * ctag_record.post_count)
          if div != 0
            c = acount / div
            similar_counts[ctag] = c
          end
        end
      end
    end

    convert_hash_to_array(similar_counts)
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

  def self.convert_hash_to_array(hash, limit = 25)
    hash.to_a.sort_by {|x| -x[1]}.slice(0, limit)
  end

  def self.convert_hash_to_string(hash)
    convert_hash_to_array(hash).flatten.join(" ")
  end
end
