module Automod
  class UpdateDynamoDbJob < Struct.new(:post_id)
    extend Memoist

    def self.enabled?
      Danbooru.config.aws_access_key_id.present?
    end

    def self.export_csv(start, stop)
      CSV.open("/tmp/automod.csv", "w") do |csv|
        csv << [
          "post_id",
          "is_approved",
          "fav_count",
          "file_size",
          "width",
          "height",
          "tag_count",
          "artist_identified",
          "artist_count",
          "character_identified",
          "character_count",
          "copyright_identified",
          "copyright_count",
          "translated",
          "comment_count",
          "note_count",
          "rating",
          "median_score",
          "is_comic"
        ]
        Post.where("created_at between ? and ?", start, stop).find_each do |post|
          data = build_hash(post)
          csv << [
            data[:post_id],
            data[:is_approved],
            data[:fav_count],
            data[:file_size],
            data[:width],
            data[:height],
            data[:tag_count],
            data[:artist_identified],
            data[:artist_count],
            data[:character_identified],
            data[:character_count],
            data[:copyright_identified],
            data[:copyright_count],
            data[:translated],
            data[:comment_count],
            data[:note_count],
            data[:rating],
            data[:median_score]
          ]
        end
      end
    end

    def self.backfill
      Post.where("id >= ?", 3_400_840).find_each do |post|
        dynamo_db_client
      end
    end

    def build_hash(post)
      data = {
        post_id: post.id,
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
        note_count: post.notes.count,
        rating: post.rating,
        median_score: median_score(post)
      }
    end

    def perform
      post = Post.find(post_id)
      data = build_hash(post)
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

    def median_score(post)
      Post.where("uploader_id = ?", post.uploader_id).where("created_at >= ?", 1.year.ago).pluck("percentile_cont(0.5) within group (order by score)").first
    end
  end
end
