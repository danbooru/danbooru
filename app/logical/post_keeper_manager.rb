class PostKeeperManager
  def self.enabled?
    PostArchive.enabled?
  end

  def self.queue_check(post_id)
    delay(queue: "default").check_and_update(post_id)
  end

  def self.evaluate(post_ids)
    total = 0
    matches = 0
    keeper_dist = {}
    uploader_dist = {}
    Post.where(id: post_ids).find_each do |post|
      keeper = check(post)
      total += 1
      if keeper != post.uploader_id
        matches += 1
        keeper_dist[keeper] ||= 0
        keeper_dist[keeper] += 1
        uploader_dist[post.uploader_id] ||= 0
        uploader_dist[post.uploader_id] += 1
      end
    end

    puts "total: #{total}"
    puts "changes: #{matches}"
    # puts "keepers:"
    # keeper_dist.each do |k, v|
    #   puts "  #{k}: #{v}"
    # end
    # puts "uploaders:"
    # uploader_dist.each do |k, v|
    #   puts "  #{k}: #{v}"
    # end
  end

  def self.check_and_update(post_id)
    post = Post.find(post_id)
    keeper_id = check(post)
    CurrentUser.as_system do
      post.update_column(:keeper_data, {uid: keeper_id})
    end
  end

  def self.check(post)
    changes = {}
    final_tags = Set.new(post.tag_array)

    # build a mapping of who added a tag first
    PostArchive.where(post_id: post.id).order("updated_at").each do |pa|
      # Rails.logger.debug "archive #{pa.id}"
      pa.added_tags.each do |at|
        # Rails.logger.debug "  checking #{at}"
        if pa.updater_id
          if !changes.has_key?(at) && final_tags.include?(at)
            # Rails.logger.debug "    adding #{at} for #{pa.updater_id}"
            changes[at] = pa.updater_id 
          end

          if pa.source_changed? && pa.source == post.source
            # Rails.logger.debug "    adding source for #{pa.updater_id}"
            changes[" source"] = pa.updater_id
          end
        else
          # Rails.logger.debug "    no updater"
        end
      end

      # easy to double count trivial changes if a user is just fixing mistakes
      # pa.removed_tags.each do |rt|
      #   Rails.logger.debug "  checking -#{rt}"
      #   if pa.updater_id
      #     if !changes.has_key?("-#{rt}") && !final_tags.include?(rt)
      #       Rails.logger.debug "    adding -#{rt} for #{pa.updater_id}"
      #       changes["-#{rt}"] = pa.updater_id
      #     end
      #   else
      #     Rails.logger.debug "    no updater"
      #   end
      # end
    end

    # add up how many changes each user has made
    ranking = changes.values.uniq.inject({}) do |h, user_id|
      # h[user_id] = changes.select {|k, v| v == user_id}.map do |tag, user_id|
      #   count = Tag.find_by_name(tag).try(:post_count) || 0
      #   1.0 / (1000 + count)
      # end.sum
      h[user_id] = changes.select {|k, v| v == user_id}.size
      h
    end

    # ranking.sort_by {|k, v| v}.each do |user_id, score|
    #   user = User.find(user_id)
    #   sum = changes.select {|k, v| v == user_id}.size
    #   Rails.logger.debug "#{user.name}: %.4f (%d)" % [score, sum]
    # end

    ranking.max_by {|k, v| v}.first
  end
end
