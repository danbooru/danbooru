module Automod
  class UpdateDynamoDbJob < Struct.new(:post_id)
    extend Memoist

    def self.enabled?
      Danbooru.config.aws_access_key_id.present?
    end

    def perform
      post = Post.find(post_id)
      data = {
        post_id: post_id,
        is_approved: is_approved?(post),
        fav_count: post.fav_count,
        file_size: post.file_size,
        width: post.image_width,
        height: post.image_height,
        tag_count: post.tag_array.size,
        artist_identified: artist_identified?(post),
        artist_count: artist_count(post),
        character_identified: character_identified?(post),
        character_count: character_count(post),
        copyright_identified: copyright_identified?(post),
        copyright_count: copyright_count(post),
        translated: is_translated?(post),
        comment_count: post.comments.count,
        note_count: post.notes.count
      }

      dynamo_db_client.put_item(table_name: "automod_events_#{Rails.env}", item: data)
    rescue ActiveRecord::RecordNotFound
      # do nothing
    end

    def dynamo_db_client
      credentials = Aws::Credentials.new(
        Danbooru.config.aws_access_key_id,
        Danbooru.config.aws_secret_access_key
      )
      Aws::DynamoDB::Client.new(
        credentials: credentials,
        region: "us-west-1"
      )
    end
    memoize :dynamo_db_client

    def is_approved?(post)
      !post.is_pending? && !post.is_deleted?
    end

    def artist_identified?(post)
      post.tags.any? { |t| t.category == Tag.categories.artist }
    end

    def character_identified?(post)
      post.tags.any? { |t| t.category == Tag.categories.character }
    end

    def copyright_identified?(post)
      post.tags.any? { |t| t.category == Tag.categories.copyright }
    end

    def artist_count(post)
      post.tags.select { |t| t.category == Tag.categories.artist }.map {|x| x.post_count}.min
    end

    def character_count(post)
      post.tags.select { |t| t.category == Tag.categories.character }.map {|x| x.post_count}.min
    end

    def copyright_count(post)
      post.tags.select { |t| t.category == Tag.categories.copyright }.map {|x| x.post_count}.min
    end

    def is_translated?(post)
      post.has_tag?("translated")
    end
  end
end
