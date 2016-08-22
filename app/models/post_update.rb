class PostUpdate
  def self.insert(post_id)
    ActiveRecord::Base.execute_sql("insert into post_updates (post_id) values (?)", post_id)
  end

  def self.get
    ActiveRecord::Base.select_values_sql("delete from post_updates returning post_id").uniq
  end

  def self.push
    return unless Danbooru.config.google_api_project

    pubsub = Google::Apis::PubsubV1::PubsubService.new
    pubsub.authorization = Google::Auth.get_application_default([Google::Apis::PubsubV1::AUTH_PUBSUB])
    topic = "projects/#{Danbooru.config.google_api_project}/topics/post_updates"
    post_ids = get()

    post_ids.in_groups_of(1_000, false).each do |group|
      request = Google::Apis::PubsubV1::PublishRequest.new(messages: group.map {|x| Google::Apis::PubsubV1::Message.new(data: x.to_s)})
      pubsub.publish_topic(topic, request)
    end
  end
end
