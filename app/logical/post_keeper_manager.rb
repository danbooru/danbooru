class PostKeeperManager
  def self.enabled?
    PostArchive.enabled?
  end

  # these are all class methods to simplify interaction with delayedjob

  # in general we want to call these methods synchronously because updating
  # the keeper data with a delay defeats the purpose. but this relies on
  # archive db being up; we don't want to block updates in case it goes down.
  # so we need to permit async updates also.

  def self.queue_check(post_id, updater_id, increment_tags)
    delay(queue: "default").check_and_update(post_id, updater_id, increment_tags, false)
  end

  def self.check_and_update(post, updater_id = nil, increment_tags = nil)
    post = Post.find(post) unless post.is_a?(Post)
    keeper_id = check(post, updater_id, increment_tags)
    post.keeper_data = {uid: keeper_id}
  end

  # because post archives might get delayed, we need to pass along the most
  # recently added tags inside the job. downside: this doesn't keep track of
  # source or rating changes. this method changes no state.
  def self.check(post, updater_id = nil, increment_tags = nil, enable_async = true)
    if enable_async && !PostArchive.test_connection
      # if archive is down, just queue this work and do it later
      queue_check(post.id, updater_id, increment_tags)
      return
    end

    changes = {}
    final_tags = Set.new(post.tag_array)

    # build a mapping of who added a tag first
    PostArchive.where(post_id: post.id).order("updated_at").each do |pa|
      pa.added_tags.each do |at|
        if pa.updater_id
          if !changes.has_key?(at) && final_tags.include?(at)
            changes[at] = pa.updater_id 
          end

          if pa.source_changed? && pa.source == post.source
            changes[" source"] = pa.updater_id
          end
        end
      end
    end

    if updater_id && increment_tags.present?
      increment_tags.each do |tag|
        if !changes.has_key?(tag)
          changes[tag] = updater_id
        end
      end
    end

    # add up how many changes each user has made
    ranking = changes.values.uniq.inject({}) do |h, user_id|
      h[user_id] = changes.select {|k, v| v == user_id}.size
      h
    end

    ranking.max_by {|k, v| v}.try(:first)
  end


  # these methods are for reporting and are not used

  # in general, unweighted changes attribution 5% of the time,
  # weighted changes attribution 12% of the time at w=1000,
  # up to 17% of the time at w=100.
  def self.evaluate(post_ids)
    total = 0
    matches = 0
    weighted_matches = 0
    keeper_dist = {}
    uploader_dist = {}
    Post.where(id: post_ids).find_each do |post|
      keeper = check(post)
      total += 1
      if keeper != post.uploader_id
        matches += 1
        # keeper_dist[keeper] ||= 0
        # keeper_dist[keeper] += 1
        # uploader_dist[post.uploader_id] ||= 0
        # uploader_dist[post.uploader_id] += 1
      end
      if check_weighted(post) != post.uploader_id
        puts post.id
        weighted_matches += 1
      end
    end

    puts "total: #{total}"
    puts "unweighted changes: #{matches}"
    puts "weighted changes: #{weighted_matches}"
    # puts "keepers:"
    # keeper_dist.each do |k, v|
    #   puts "  #{k}: #{v}"
    # end
    # puts "uploaders:"
    # uploader_dist.each do |k, v|
    #   puts "  #{k}: #{v}"
    # end
  end

  def self.print_weighted(post, w = 1000)
    changes = {}
    final_tags = Set.new(post.tag_array)

    # build a mapping of who added a tag first
    PostArchive.where(post_id: post.id).order("updated_at").each do |pa|
      pa.added_tags.each do |at|
        if pa.updater_id
          if !changes.has_key?(at) && final_tags.include?(at)
            changes[at] = pa.updater_id 
          end

          if pa.source_changed? && pa.source == post.source
            changes[" source"] = pa.updater_id
          end
        end
      end
    end

    # add up how many changes each user has made
    ranking = changes.values.uniq.inject({}) do |h, user_id|
      h[user_id] = changes.select {|k, v| v == user_id}.map do |tag, user_id|
        count = Tag.find_by_name(tag).try(:post_count) || 0
        1.0 / (w + count)
      end.sum
      h
    end

    ranking.sort_by {|k, v| v}.each do |user_id, score|
      user = User.find(user_id)
      sum = changes.select {|k, v| v == user_id}.size
      Rails.logger.debug "#{user.name}: %.4f (%d)" % [score, sum]
    end
  end

  def self.check_weighted(post, w = 1000)
    changes = {}
    final_tags = Set.new(post.tag_array)

    # build a mapping of who added a tag first
    PostArchive.where(post_id: post.id).order("updated_at").each do |pa|
      pa.added_tags.each do |at|
        if pa.updater_id
          if !changes.has_key?(at) && final_tags.include?(at)
            changes[at] = pa.updater_id 
          end

          if pa.source_changed? && pa.source == post.source
            changes[" source"] = pa.updater_id
          end
        end
      end
    end

    # add up how many changes each user has made
    ranking = changes.values.uniq.inject({}) do |h, user_id|
      h[user_id] = changes.select {|k, v| v == user_id}.map do |tag, user_id|
        count = Tag.find_by_name(tag).try(:post_count) || 0
        1.0 / (w + count)
      end.sum
      h
    end

    ranking.max_by {|k, v| v}.first
  end

end
