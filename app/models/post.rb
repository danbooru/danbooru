class Post < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr, :old_tag_string
  belongs_to :updater, :class_name => "User"
  has_one :unapproval
  after_destroy :delete_files
  after_save :create_version
  
  before_save :merge_old_tags
  before_save :normalize_tags
  before_save :create_tags
  before_save :update_tag_post_counts
  before_save :set_tag_counts

  has_many :versions, :class_name => "PostVersion"
  
  module FileMethods
    def delete_files
      FileUtils.rm_f(file_path)
      FileUtils.rm_f(medium_file_path)
      FileUtils.rm_f(large_file_path)
      FileUtils.rm_f(thumb_file_path)
    end

    def file_path_prefix
      Rails.env == "test" ? "test." : ""
    end
    
    def file_path
      "#{Rails.root}/public/data/original/#{file_path_prefix}#{md5}.#{file_ext}"
    end
    
    def medium_file_path
      "#{Rails.root}/public/data/medium/#{file_path_prefix}#{md5}.jpg"
    end

    def large_file_path
      "#{Rails.root}/public/data/large/#{file_path_prefix}#{md5}.jpg"
    end

    def thumb_file_path
      "#{Rails.root}/public/data/thumb/#{file_path_prefix}#{md5}.jpg"
    end

    def file_url
      "/data/original/#{file_path_prefix}#{md5}.#{file_ext}"
    end
    
    def medium_file_url
      "/data/medium/#{file_path_prefix}#{md5}.jpg"
    end

    def large_file_url
      "/data/large/#{file_path_prefix}#{md5}.jpg"
    end

    def thumb_file_url
      "/data/thumb/#{file_path_prefix}#{md5}.jpg"
    end
    
    def file_url_for(user)
      case user.default_image_size
      when "medium"
        medium_file_url
        
      when "large"
        large_file_url
        
      else
        file_url
      end
    end
  end
  
  module ImageMethods
    def has_medium?
      image_width > Danbooru.config.medium_image_width
    end
    
    def has_large?
      image_width > Danbooru.config.large_image_width
    end
  end
  
  module ModerationMethods
    def unapprove!(reason, current_user, current_ip_addr)
      raise Unapproval::Error.new("You can't unapprove a post more than once") if is_flagged?
      
      unapproval = create_unapproval(
        :unapprover_id => current_user.id,
        :unapprover_ip_addr => current_ip_addr,
        :reason => reason
      )
      
      if unapproval.errors.any?
        raise Unapproval::Error.new(unapproval.errors.full_messages.join("; "))
      end
      
      update_attribute(:is_flagged, true)
    end
    
    def delete!
      update_attribute(:is_deleted, true)
    end
    
    def approve!
      update_attributes(:is_deleted => false, :is_pending => false)
    end
  end
  
  module PresenterMethods
    def pretty_rating
      case rating
      when "q"
        "Questionable"
        
      when "e"
        "Explicit"
        
      when "s"
        "Safe"
      end
    end
  end
  
  module VersionMethods
    def create_version
      version = versions.create(
        :source => source,
        :rating => rating,
        :tag_string => tag_string,
        :updater_id => updater_id,
        :updater_ip_addr => updater_ip_addr
      )
      
      raise PostVersion::Error.new(version.errors.full_messages.join("; ")) if version.errors.any?
    end
  end
  
  module TagMethods
    def tag_array
      @tag_array ||= Tag.scan_tags(tag_string)
    end
    
    def tag_array_was
      @tag_array_was ||= Tag.scan_tags(tag_string_was)
    end
    
    def create_tags
      set_tag_string(tag_array.map {|x| Tag.find_or_create_by_name(x).name}.join(" "))
    end
    
    def update_tag_post_counts
      decrement_tags = tag_array_was - tag_array
      increment_tags = tag_array - tag_array_was
      execute_sql("UPDATE tags SET post_count = post_count - 1 WHERE name IN (?)", decrement_tags) if decrement_tags.any?
      execute_sql("UPDATE tags SET post_count = post_count + 1 WHERE name IN (?)", increment_tags) if increment_tags.any?
    end
    
    def set_tag_counts
      self.tag_count = 0
      self.tag_count_general = 0
      self.tag_count_artist = 0
      self.tag_count_copyright = 0
      self.tag_count_character = 0
      
      categories = Tag.categories_for(tag_array)
      categories.each_value do |category|
        self.tag_count += 1
        
        case category
        when Tag.categories.general
          self.tag_count_general += 1
          
        when Tag.categories.artist
          self.tag_count_artist += 1
          
        when Tag.categories.copyright
          self.tag_count_copyright += 1
          
        when Tag.categories.character
          self.tag_count_character += 1
        end
      end
    end
    
    def merge_old_tags
      if old_tag_string
        # If someone else committed changes to this post before we did,
        # then try to merge the tag changes together.
        current_tags = Tag.scan_tags(tag_string_was)
        new_tags = tag_array()
        old_tags = Tag.scan_tags(old_tag_string)        
        set_tag_string(((current_tags + new_tags) - old_tags + (current_tags & new_tags)).uniq.join(" "))
      end
    end
    
    def reset_tag_array_cache
      @tag_array = nil
      @tag_array_was = nil
    end
    
    def set_tag_string(string)
      self.tag_string = string
      reset_tag_array_cache
    end
    
    def normalize_tags
      normalized_tags = Tag.scan_tags(tag_string)
      normalized_tags = TagAlias.to_aliased(normalized_tags)
      normalized_tags = TagImplication.with_descendants(normalized_tags)
      normalized_tags = filter_metatags(normalized_tags)
      set_tag_string(normalized_tags.uniq.join(" "))
    end
    
    def filter_metatags(tags)
      tags.reject {|tag| tag =~ /\A(?:pool|rating|fav|approver|uploader):/}
    end
  end
  
  module FavoriteMethods
    def add_favorite(user)
      self.fav_string += " fav:#{user.name}"
      self.fav_string.strip!
    end
    
    def remove_favorite(user)
      self.fav_string.gsub!(/fav:#{user.name}\b\s*/, " ")
      self.fav_string.strip!
    end
  end
  
  module SearchMethods
    class SearchError < Exception ; end
    
    def add_range_relation(arr, field, relation)
      case arr[0]
      when :eq
        relation.where(["#{field} = ?", arr[1]])

      when :gt
        relation.where(["#{field} > ?", arr[1]])

      when :gte
        relation.where(["#{field} >= ?", arr[1]])

      when :lt
        relation.where(["#{field} < ?", arr[1]])

      when :lte
        relation.where(["#{field} <= ?", arr[1]])

      when :between
        relation.where(["#{field} BETWEEN ? AND ?", arr[1], arr[2]])

      else
        relation
      end
    end

    def escape_string_for_tsquery(array)
      array.map do |token|
        escaped_token = token.gsub(/\\|'/, '\0\0\0\0').gsub("?", "\\\\77").gsub("%", "\\\\37")
        "''" + escaped_token + "''"
      end
    end
    
    def add_tag_string_search_relation(tags, relation)
      tag_query_sql = []

      if tags[:include].any?
        tag_query_sql << "(" + escape_string_for_tsquery(tags[:include]).join(" | ") + ")"
      end
  
      if tags[:related].any?
        raise SearchError.new("You cannot search for more than #{Danbooru.config.tag_query_limit} tags at a time") if tags[:related].size > Danbooru.config.tag_query_limit
        tag_query_sql << "(" + escape_string_for_tsquery(tags[:related]).join(" & ") + ")"
      end

      if tags[:exclude].any?
        raise SearchError.new("You cannot search for more than #{Danbooru.config.tag_query_limit} tags at a time") if tags[:exclude].size > Danbooru.config.tag_query_limit

        if tags[:related].any? || tags[:include].any?
          tag_query_sql << "!(" + escape_string_for_tsquery(tags[:exclude]).join(" | ") + ")"
        else
          raise SearchError.new("You cannot search for only excluded tags")
        end
      end

      if tag_query_sql.any?
        relation = relation.where("posts.tag_index @@ to_tsquery('danbooru', E'" + tag_query_sql.join(" & ") + "')")
      end
      
      relation
    end
    
    def add_tag_subscription_relation(subscriptions, relation)
      subscriptions.each do |subscription|
        subscription =~ /^(.+?):(.+)$/
        user_name = $1 || subscription
        subscription_name = $2

        user = User.find_by_name(user_name)

        if user
          post_ids = TagSubscription.find_post_ids(user.id, subscription_name)
          relation = relation.where(["posts.id IN (?)", post_ids])
        end
      end
      
      relation
    end

    def find_by_tags(q, options = {})
      unless q.is_a?(Hash)
        q = Tag.parse_query(q)
      end
      
      relation = where()

      relation = add_range_relation(q[:post_id], "posts.id", relation)
      relation = add_range_relation(q[:mpixels], "posts.width * posts.height / 1000000.0", relation)
      relation = add_range_relation(q[:width], "posts.image_width", relation)
      relation = add_range_relation(q[:height], "posts.image_height", relation)
      relation = add_range_relation(q[:score], "posts.score", relation)
      relation = add_range_relation(q[:filesize], "posts.file_size", relation)
      relation = add_range_relation(q[:date], "posts.created_at::date", relation)
      relation = add_range_relation(q[:general_tag_count], "posts.tag_count_general", relation)
      relation = add_range_relation(q[:artist_tag_count], "posts.tag_count_artist", relation)
      relation = add_range_relation(q[:copyright_tag_count], "posts.tag_count_copyright", relation)
      relation = add_range_relation(q[:character_tag_count], "posts.tag_count_character", relation)
      relation = add_range_relation(q[:tag_count], "posts.tag_count", relation)      

      if options[:before_id]
        relation = relation.where(["posts.id < ?", options[:before_id]])
      end

      if q[:md5].any?
        relation = relation.where(["posts.md5 IN (?)", q[:md5]])
      end

      if q[:status] == "deleted"
        relation = relation.where("posts.is_deleted = TRUE")
      elsif q[:status] == "pending"
        relation = relation.where("posts.is_pending = TRUE")
      elsif q[:status] == "flagged"
        relation = relation.where("posts.is_flagged = TRUE")
      else
        relation = relation.where("posts.is_deleted = FALSE")
      end

      if q[:source].is_a?(String)
        relation = relation.where(["posts.source LIKE ? ESCAPE E'\\\\'", q[:source]])
      end

      if q[:subscriptions].any?
        relation = add_tag_subscription_relation(q[:subscriptions], relation)
      end

      relation = add_tag_string_search_relation(q[:tags], relation)

      if q[:rating] == "q"
        relation = relation.where("posts.rating = 'q'")
      elsif q[:rating] == "s"
        relation = relation.where("posts.rating = 's'")
      elsif q[:rating] == "e"
        relation = relation.where("posts.rating = 'e'")
      end

      if q[:rating_negated] == "q"
        relation = relation.where("posts.rating <> 'q'")
      elsif q[:rating_negated] == "s"
        relation = relation.where("posts.rating <> 's'")
      elsif q[:rating_negated] == "e"
        relation = relation.where("posts.rating <> 'e'")
      end
      
      case q[:order]
      when "id", "id_asc"
        relation = relation.order("posts.id")

      when "id_desc"
        relation = relation.order("posts.id DESC")

      when "score", "score_desc"
        relation = relation.order("posts.score DESC, posts.id DESC")

      when "score_asc"
        relation = relation.order("posts.score, posts.id DESC")

      when "mpixels", "mpixels_desc"
        # Use "w*h/1000000", even though "w*h" would give the same result, so this can use
        # the posts_mpixels index.
        relation = relation.order("posts.image_width * posts.image_height / 1000000.0 DESC, posts.id DESC")

      when "mpixels_asc"
        relation = relation.order("posts.image_width * posts.image_height / 1000000.0, posts.id DESC")

      when "portrait"
        relation = relation.order("1.0 * image_width / GREATEST(1, image_height), posts.id DESC")

      when "landscape"
        relation = relation.order("1.0 * image_width / GREATEST(1, image_height) DESC, posts.id DESC")

      when "filesize", "filesize_desc"
        relation = relation.order("posts.file_size DESC")

      when "filesize_asc"
        relation = relation.order("posts.file_size")

      else
        relation = relation.order("posts.id DESC")
      end

      if options[:limit]
        relation = relation.limit(options[:limit])
      end

      if options[:offset]
        relation = relation.offset(options[:offset])
      end
      
      relation
    end
  end
  
  module UploaderMethods
    def uploader_id=(user_id)
      self.uploader = User.find(user_id)
    end
    
    def uploader_id
      uploader.id
    end
    
    def uploader_name
      uploader_string[9..-1]
    end
    
    def uploader
      User.find_by_name(uploader_name)
    end
    
    def uploader=(user)
      self.uploader_string = "uploader:#{user.name}"
    end
  end
  
  module PoolMethods
    def add_pool(pool)
      self.pool_string += " pool:#{pool.name}"
      self.pool_string.strip!
    end
    
    def remove_pool(user_id)
      self.pool_string.gsub!(/pool:#{pool.name}\b\s*/, " ")
      self.pool_string.strip!
    end
  end
  
  include FileMethods
  include ImageMethods
  include ModerationMethods
  include PresenterMethods
  include VersionMethods
  include TagMethods
  include FavoriteMethods
  include UploaderMethods
  include PoolMethods
  extend SearchMethods
  
  def reload(options = nil)
    super
    reset_tag_array_cache
  end
end
