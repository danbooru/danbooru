class Post < ActiveRecord::Base
  class ApprovalError < Exception ; end
  class DisapprovalError < Exception ; end
  class SearchError < Exception ; end
  
  attr_accessor :old_tag_string, :old_parent_id
  after_destroy :delete_files
  after_save :create_version
  after_save :update_parent_on_save
  before_save :merge_old_tags
  before_save :normalize_tags
  before_save :create_tags
  before_save :update_tag_post_counts
  before_save :set_tag_counts
  before_validation :initialize_uploader, :on => :create
  belongs_to :updater, :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :parent, :class_name => "Post"
  has_one :upload, :dependent => :destroy
  has_many :flags, :class_name => "PostFlag", :dependent => :destroy
  has_many :appeals, :class_name => "PostAppeal", :dependent => :destroy
  has_many :versions, :class_name => "PostVersion", :dependent => :destroy, :order => "post_versions.id ASC"
  has_many :votes, :class_name => "PostVote", :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :comments
  has_many :children, :class_name => "Post", :foreign_key => "parent_id", :order => "posts.id"
  has_many :disapprovals, :class_name => "PostDisapproval"
  validates_uniqueness_of :md5
  validates_presence_of :parent, :if => lambda {|rec| !rec.parent_id.nil?}
  validate :validate_parent_does_not_have_a_parent
  attr_accessible :source, :rating, :tag_string, :old_tag_string, :last_noted_at
  scope :pending, where(["is_pending = ?", true])
  scope :pending_or_flagged, where(["(is_pending = ? OR is_flagged = ?)", true, true])
  scope :undeleted, where(["is_deleted = ?", false])
  scope :deleted, where(["is_deleted = ?", true])
  scope :visible, lambda {|user| Danbooru.config.can_user_see_post_conditions(user)}
  scope :commented_before, lambda {|date| where("last_commented_at < ?", date).order("last_commented_at DESC")}
  scope :noted_before, lambda {|date| where("last_noted_at < ?", date).order("last_noted_at DESC")}
  scope :for_user, lambda {|user_id| where(["uploader_string = ?", "uploader:#{user_id}"])}
  scope :available_for_moderation, lambda {where(["id NOT IN (SELECT pd.post_id FROM post_disapprovals pd WHERE pd.user_id = ?)", CurrentUser.id])}
  scope :hidden_from_moderation, lambda {where(["id IN (SELECT pd.post_id FROM post_disapprovals pd WHERE pd.user_id = ?)", CurrentUser.id])}
  scope :tag_match, lambda {|query| Post.tag_match_helper(query)}
  scope :positive, where("score > 1")
  scope :negative, where("score < -1")
  search_methods :tag_match
  scope :after_id, Proc.new {|num|
    if num.present?
      where("id > ?", num.to_i).reorder("id asc")
    else
      where("true")
    end
  }
  scope :before_id, Proc.new {|num|
    if num.present?
      where("id < ?", num.to_i).reorder("id desc")
    else
      where("true")
    end
  }
    
  module FileMethods
    def delete_files
      FileUtils.rm_f(file_path)
      FileUtils.rm_f(medium_file_path)
      FileUtils.rm_f(large_file_path)
      FileUtils.rm_f(preview_file_path)
    end

    def file_path_prefix
      Rails.env == "test" ? "test." : ""
    end
    
    def file_path
      "#{Rails.root}/public/data/original/#{file_path_prefix}#{md5}.#{file_ext}"
    end
    
    def medium_file_path
      if has_medium?
        "#{Rails.root}/public/data/medium/#{file_path_prefix}#{md5}.jpg"
      else
        file_path
      end
    end

    def large_file_path
      if has_large?
        "#{Rails.root}/public/data/large/#{file_path_prefix}#{md5}.jpg"
      else
        file_path
      end
    end

    def preview_file_path
      "#{Rails.root}/public/data/preview/#{file_path_prefix}#{md5}.jpg"
    end

    def file_url
      "/data/original/#{file_path_prefix}#{md5}.#{file_ext}"
    end
    
    def medium_file_url
      if has_medium?
        "/data/medium/#{file_path_prefix}#{md5}.jpg"
      else
        file_url
      end
    end

    def large_file_url
      if has_large?
        "/data/large/#{file_path_prefix}#{md5}.jpg"
      else
        medium_file_url
      end
    end

    def preview_file_url
      "/data/preview/#{file_path_prefix}#{md5}.jpg"
    end
    
    def file_url_for(user)
      case user.default_image_size
      when "medium"
        if image_width > Danbooru.config.medium_image_width
          medium_file_url
        else
          file_url
        end
        
      when "large"
        if image_width > Danbooru.config.large_image_width
          large_file_url
        else
          file_url
        end
        
      else
        file_url
      end
    end
    
    def file_path_for(user)
      case user.default_image_size
      when "medium"
        if image_width > Danbooru.config.medium_image_width
          medium_file_path
        else
          file_path
        end
        
      when "large"
        if image_width > Danbooru.config.large_image_width
          large_file_path
        else
          file_path
        end
        
      else
        file_path
      end
    end
    
    def is_image?
      file_ext =~ /jpg|gif|png/
    end
    
    def is_flash?
      file_ext =~ /swf/
    end
  end
  
  module ImageMethods
    def has_medium?
      image_width > Danbooru.config.medium_image_width
    end
    
    def has_large?
      image_width > Danbooru.config.large_image_width
    end
    
    def medium_image_width
      [Danbooru.config.medium_image_width, image_width].min
    end
    
    def large_image_width
      [Danbooru.config.large_image_width, image_width].min
    end
    
    def medium_image_height
      ratio = Danbooru.config.medium_image_width.to_f / image_width.to_f
      if ratio < 1
        (image_height * ratio).to_i
      else
        image_height
      end
    end
    
    def large_image_height
      ratio = Danbooru.config.large_image_width.to_f / image_width.to_f
      if ratio < 1
        (image_height * ratio).to_i
      else
        image_height
      end
    end
    
    def image_width_for(user)
      case user.default_image_size
      when "medium"
        medium_image_width
        
      when "large"
        large_image_width
        
      else
        image_width
      end
    end
    
    def image_height_for(user)
      case user.default_image_size
      when "medium"
        medium_image_height
        
      when "large"
        large_image_height
        
      else
        image_height
      end
    end
  end
  
  module ApprovalMethods
    def is_approvable?
      (is_pending? || is_flagged? || is_deleted?) && approver_string != "approver:#{CurrentUser.name}"
    end
    
    def flag!(reason)
      flag = flags.create(:reason => reason)
      
      if flag.errors.any?
        raise PostFlag::Error.new(flag.errors.full_messages.join("; "))
      end

      update_attribute(:is_flagged, true)
    end
    
    def appeal!(reason)
      appeal = appeals.create(:reason => reason)
      
      if appeal.errors.any?
        raise PostAppeal::Error.new(appeal.errors.full_messages.join("; "))
      end
    end

    def approve!
      raise ApprovalError.new("You have previously approved this post and cannot approve it again") if approver_string == "approver:#{CurrentUser.name}"
      
      flags.each {|x| x.resolve!}
      self.is_flagged = false
      self.is_pending = false
      self.is_deleted = false
      self.approver_string = "approver:#{CurrentUser.name}"
      save!
    end
  end
  
  module PresenterMethods
    def presenter
      @presenter ||= PostPresenter.new(self)
    end

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
    
    def increment_tag_post_counts
      execute_sql("UPDATE tags SET post_count = post_count + 1 WHERE name IN (?)", tag_array) if tag_array.any?
    end
    
    def decrement_tag_post_counts
      execute_sql("UPDATE tags SET post_count = post_count - 1 WHERE name IN (?)", tag_array) if tag_array.any?
    end
    
    def update_tag_post_counts
      decrement_tags = tag_array_was - tag_array
      increment_tags = tag_array - tag_array_was
      execute_sql("UPDATE tags SET post_count = post_count - 1 WHERE name IN (?)", decrement_tags) if decrement_tags.any?
      execute_sql("UPDATE tags SET post_count = post_count + 1 WHERE name IN (?)", increment_tags) if increment_tags.any?
      decrement_tags.each do |tag|
        expire_cache(tag)
      end
      increment_tags.each do |tag|
        expire_cache(tag)
      end
      expire_cache("")
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
        current_tags = tag_array_was()
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
    
    def has_tag?(tag)
      tag_string =~ /(?:^| )#{tag}(?:$| )/
    end
  end
  
  module FavoriteMethods
    def delete_favorites
      Favorite.delete_post(id)
    end
    
    def favorited_by?(user_id)
      fav_string =~ /(?:\A| )fav:#{user_id}(?:\Z| )/
    end
    
    def append_user_to_fav_string(user_id)
      update_attribute(:fav_string, (fav_string + " fav:#{user_id}").strip)
    end
    
    def add_favorite!(user)
      return if favorited_by?(user.id)
      append_user_to_fav_string(user.id)
      user.add_favorite!(self)
    end
    
    def delete_user_from_fav_string(user_id)
      update_attribute(:fav_string, fav_string.gsub(/(?:\A| )fav:#{user_id}(?:\Z| )/, " ").strip)
    end
    
    def remove_favorite!(user)
      return unless favorited_by?(user.id)
      delete_user_from_fav_string(user.id)
      user.remove_favorite!(self)
    end
    
    def favorited_user_ids
      fav_string.scan(/\d+/)
    end
  end
  
  module SearchMethods
    def add_range_relation(arr, field, relation)
      return relation if arr.nil?
      
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

    def tag_match_helper(q)
      unless q.is_a?(Hash)
        q = Tag.parse_query(q)
      end
      
      relation = Post.scoped

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

      if q[:md5]
        relation = relation.where(["posts.md5 IN (?)", q[:md5]])
      end
      
      if q[:status] == "pending"
        relation = relation.where("posts.is_pending = TRUE")
      elsif q[:status] == "flagged"
        relation = relation.where("posts.is_flagged = TRUE")
      elsif q[:status] == "deleted"
        relation = relation.where("posts.is_deleted = TRUE")
      end

      if q[:source]
        relation = relation.where(["posts.source LIKE ? ESCAPE E'\\\\'", q[:source]])
      end

      if q[:subscriptions]
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
        relation = relation.order("1.0 * posts.image_width / GREATEST(1, posts.image_height), posts.id DESC")

      when "landscape"
        relation = relation.order("1.0 * posts.image_width / GREATEST(1, posts.image_height) DESC, posts.id DESC")

      when "filesize", "filesize_desc"
        relation = relation.order("posts.file_size DESC")

      when "filesize_asc"
        relation = relation.order("posts.file_size")

      else
        relation = relation.order("posts.id DESC")
      end

      relation
    end
  end
  
  module UploaderMethods
    def initialize_uploader
      self.uploader = CurrentUser.user
      self.uploader_ip_addr = CurrentUser.ip_addr
    end
    
    def uploader_id=(user_id)
      self.uploader = User.find(user_id)
    end
    
    def uploader_id
      uploader_string[9..-1].to_i
    end
    
    def uploader_name
      User.id_to_name(uploader_id)
    end
    
    def uploader
      User.find(uploader_id)
    end
    
    def uploader=(user)
      self.uploader_string = "uploader:#{user.id}"
    end
  end
  
  module PoolMethods
    def pools
      @pools ||= begin
        pool_ids = pool_string.scan(/\d+/)
        Pool.where(["id in (?)", pool_ids])
      end
    end
    
    def belongs_to_pool?(pool)
      pool_string =~ /(?:\A| )pool:#{pool.id}(?:\Z| )/
    end
    
    def add_pool!(pool)
      return if belongs_to_pool?(pool)
      update_attribute(:pool_string, "#{pool_string} pool:#{pool.id}".strip)
      pool.add!(self)
    end
    
    def remove_pool!(pool)
      return unless belongs_to_pool?(pool)
      update_attribute(:pool_string, pool_string.gsub(/(?:\A| )pool:#{pool.id}(?:\Z| )/, " ").strip)
      pool.remove!(self)
    end
  end
  
  module VoteMethods
    def can_be_voted_by?(user)
      !votes.exists?(["user_id = ?", user.id])
    end

    def vote!(score)
      if can_be_voted_by?(CurrentUser.user)
        if score == "up"
          increment!(:score)
          increment!(:up_score)
        elsif score == "down"
          decrement!(:score)
          decrement!(:down_score)
        end

        votes.create(:score => score)
      else
        raise PostVote::Error.new("You have already voted for this comment")
      end
    end
  end
  
  module CountMethods
    def get_count_from_cache(tags)
      Cache.get(count_cache_key(tags))
    end
    
    def set_count_in_cache(tags, count)
      if count < 100
        expiry = 0
      else
        expiry = (count * 4).minutes
      end
      
      Cache.put(count_cache_key(tags), count, expiry)
    end
    
    def count_cache_key(tags)
      "pfc:#{Cache.sanitize(tags)}"
    end
    
    def fast_count(tags = "")
      tags = tags.to_s
      count = get_count_from_cache(tags)
      if count.nil?
        count = Post.tag_match(tags).undeleted.count
        if count > Danbooru.config.posts_per_page * 10
          set_count_in_cache(tags, count)
        end
      end
      count
    end
  end
  
  module CacheMethods
    def expire_cache(tag_name)
      if Post.fast_count("") < 1000
        Cache.delete(Post.count_cache_key(""))
      end
      Cache.delete(Post.count_cache_key(tag_name))
    end
  end

  module ParentMethods
    # A parent has many children. A child belongs to a parent. 
    # A parent cannot have a parent.
    #
    # After deleting a child:
    # - Move favorites to parent.
    # - Does the parent have any active children?
    #   - Yes: Done.
    #   - No: Update parent's has_children flag to false.
    #
    # After deleting a parent:
    # - Move favorites to the first child.
    # - Reparent all active children to the first active child.
    
    module ClassMethods
      def update_has_children_flag_for(post_id)
        has_children = Post.exists?(["is_deleted = ? AND parent_id = ?", false, post_id])
        execute_sql("UPDATE posts SET has_children = ? WHERE id = ?", has_children, post_id)
      end
    
      def recalculate_has_children_for_all_posts
        transaction do
          execute_sql("UPDATE posts SET has_children = false WHERE has_children = true")
          execute_sql("UPDATE posts SET has_children = true WHERE id IN (SELECT p.parent_id FROM posts p WHERE p.parent_id IS NOT NULL AND is_deleted = FALSE)")
        end
      end
    end
  
    def self.included(m)
      m.extend(ClassMethods)
    end

    def validate_parent_does_not_have_a_parent
      return if parent.nil?
      if !parent.parent.nil?
        errors.add(:parent, "can not have a parent")
      end
    end
    
    def update_parent_on_destroy
      Post.update_has_children_flag_for(parent_id)
      Post.update_has_children_flag_for(parent_id_was) if parent_id_was && parent_id != parent_id_was
    end
    
    def update_children_on_destroy
      if children.size == 0
        # do nothing
      elsif children.size == 1
        children.first.update_attribute(:parent_id, nil)
      else
        cached_children = children
        cached_children[1..-1].each do |child|
          child.update_attribute(:parent_id, cached_children[0].id)
        end
        cached_children[0].update_attribute(:parent_id, nil)
      end
    end

    def update_parent_on_save
      if parent_id == parent_id_was
        # do nothing
      elsif !parent_id_was.nil?
        Post.update_has_children_flag_for(parent_id)
        Post.update_has_children_flag_for(parent_id_was)
      else
        Post.update_has_children_flag_for(parent_id)
      end
    end
    
    def give_favorites_to_parent
      return if parent.nil?

      favorited_user_ids.each do |user_id|
        parent.add_favorite!(User.find(user_id))
        remove_favorite!(User.find(user_id))
      end
    end
  end
  
  module DeletionMethods
    def delete!
      Post.transaction do
        give_favorites_to_parent
        update_children_on_destroy
        delete_favorites
        decrement_tag_post_counts
        update_attribute(:is_deleted, true)
        update_parent_on_destroy
        tag_array.each {|x| expire_cache(x)}
      end
    end
    
    def undelete!
      update_attribute(:is_deleted, false)
      tag_array.each {|x| expire_cache(x)}
      update_parent_on_save
    end
  end
  
  module VersionMethods
    def create_version
      if created_at == updated_at
        versions.create(
          :rating => rating,
          :source => source,
          :add_tags => tag_string,
          :parent_id => parent_id
        )
      else
        versions.create(
          :rating => rating_changed? ? rating : nil,
          :source => source_changed? ? source : nil,
          :add_tags => (tag_array - tag_array_was).join(" "),
          :del_tags => (tag_array_was - tag_array).join(" "),
          :parent_id => parent_id_changed? ? parent_id : nil
        )
      end
    end
    
    def revert_to(target)
      base_tags = []
      base_rating = "q"
      base_source = nil
      base_parent_id = nil
      
      versions.each do |version|
        if version.id <= target.id
          base_tags += version.add_tag_array
          base_tags -= version.del_tag_array
          base_rating = version.rating if version.rating
          base_source = version.source if version.source
          base_parent_id = version.parent_id if version.parent_id
        end
      end
      
      self.tag_string = base_tags.sort.join(" ")
      self.rating = base_rating
      self.source = base_source
      self.parent_id = base_parent_id
    end
    
    def revert_to!(target)
      revert_to(target)
      save!
    end
  end
  
  include FileMethods
  include ImageMethods
  include ApprovalMethods
  include PresenterMethods
  include TagMethods
  include FavoriteMethods
  include UploaderMethods
  include PoolMethods
  extend SearchMethods
  include VoteMethods
  extend CountMethods
  include CacheMethods
  include ParentMethods
  include DeletionMethods
  include VersionMethods
  
  def reload(options = nil)
    super
    reset_tag_array_cache
  end
end

Post.connection.extend(PostgresExtensions)
