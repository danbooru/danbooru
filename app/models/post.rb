class Post < ActiveRecord::Base
  class ApprovalError < Exception ; end
  class DisapprovalError < Exception ; end
  class SearchError < Exception ; end
  
  attr_accessor :old_tag_string, :old_parent_id, :has_constraints
  after_destroy :delete_files
  after_destroy :delete_remote_files
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
  belongs_to :uploader, :class_name => "User"
  belongs_to :parent, :class_name => "Post"
  has_one :upload, :dependent => :destroy
  has_many :flags, :class_name => "PostFlag", :dependent => :destroy
  has_many :appeals, :class_name => "PostAppeal", :dependent => :destroy
  has_many :versions, :class_name => "PostVersion", :dependent => :destroy, :order => "post_versions.id ASC"
  has_many :votes, :class_name => "PostVote", :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :comments, :order => "comments.id"
  has_many :children, :class_name => "Post", :foreign_key => "parent_id", :order => "posts.id"
  has_many :disapprovals, :class_name => "PostDisapproval"
  validates_uniqueness_of :md5
  validates_presence_of :parent, :if => lambda {|rec| !rec.parent_id.nil?}
  validate :validate_parent_does_not_have_a_parent
  attr_accessible :source, :rating, :tag_string, :old_tag_string, :last_noted_at, :parent_id, :as => [:member, :privileged, :contributor, :janitor, :moderator, :admin, :default]
  attr_accessible :is_rating_locked, :is_note_locked, :as => [:janitor, :moderator, :admin]
  attr_accessible :is_status_locked, :as => [:admin]
  scope :pending, where(["is_pending = ?", true])
  scope :pending_or_flagged, where(["(is_pending = ? OR is_flagged = ?)", true, true])
  scope :undeleted, where(["is_deleted = ?", false])
  scope :deleted, where(["is_deleted = ?", true])
  scope :visible, lambda {|user| Danbooru.config.can_user_see_post_conditions(user)}
  scope :commented_before, lambda {|date| where("last_commented_at < ?", date).order("last_commented_at DESC")}
  scope :has_notes, where("last_noted_at is not null")
  scope :for_user, lambda {|user_id| where(["uploader_id = ?", user_id])}
  scope :available_for_moderation, lambda {|hidden| hidden.present? ? where(["id IN (SELECT pd.post_id FROM post_disapprovals pd WHERE pd.user_id = ?)", CurrentUser.id]) : where(["id NOT IN (SELECT pd.post_id FROM post_disapprovals pd WHERE pd.user_id = ?)", CurrentUser.id])}
  scope :hidden_from_moderation, lambda {where(["id IN (SELECT pd.post_id FROM post_disapprovals pd WHERE pd.user_id = ?)", CurrentUser.id])}
  scope :tag_match, lambda {|query| PostQueryBuilder.new(query).build}
  scope :positive, where("score > 1")
  scope :negative, where("score < -1")
  scope :updater_name_matches, lambda {|name| where("updater_id = (select _.id from users _ where lower(_.name) = ?)", name.downcase)}
  search_methods :tag_match, :updater_name_matches
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
    def distribute_files
      RemoteFileManager.new(file_path).distribute
      RemoteFileManager.new(real_preview_file_path).distribute
      RemoteFileManager.new(ssd_preview_file_path).distribute if Danbooru.config.ssd_path
      RemoteFileManager.new(large_file_path).distribute if has_large?
    end
    
    def delete_remote_files
      RemoteFileManager.new(file_path).delete
      RemoteFileManager.new(real_preview_file_path).delete
      RemoteFileManager.new(ssd_preview_file_path).delete if Danbooru.config.ssd_path
      RemoteFileManager.new(large_file_path).delete if has_large?
    end
    
    def delete_files
      FileUtils.rm_f(file_path)
      FileUtils.rm_f(large_file_path)
      FileUtils.rm_f(ssd_preview_file_path) if Danbooru.config.ssd_path
      FileUtils.rm_f(real_preview_file_path)
    end

    def file_path_prefix
      Rails.env == "test" ? "test." : ""
    end
    
    def file_path
      "#{Rails.root}/public/data/#{file_path_prefix}#{md5}.#{file_ext}"
    end
    
    def large_file_path
      if has_large?
        "#{Rails.root}/public/data/sample/#{file_path_prefix}#{Danbooru.config.large_image_prefix}#{md5}.jpg"
      else
        file_path
      end
    end
    
    def real_preview_file_path
      "#{Rails.root}/public/data/preview/#{file_path_prefix}#{md5}.jpg"
    end
    
    def ssd_preview_file_path
      "#{Danbooru.config.ssd_path}/public/data/preview/#{file_path_preview}#{md5}.jpg"
    end

    def preview_file_path
      if Danbooru.config.ssd_path
        ssd_preview_file_path
      else
        real_preview_file_path
      end
    end

    def file_url
      "/data/#{file_path_prefix}#{md5}.#{file_ext}"
    end
    
    def large_file_url
      if has_large?
        "/data/sample/#{file_path_prefix}#{Danbooru.config.large_image_prefix}#{md5}.jpg"
      else
        file_url
      end
    end

    def preview_file_url
      if is_flash?
        return "/data/preview/150x150-flash.png"
      end
      
      if Danbooru.config.ssd_path
        "/ssd/data/preview/#{file_path_prefix}#{md5}.jpg"
      else
        "/data/preview/#{file_path_prefix}#{md5}.jpg"
      end
    end
    
    def file_url_for(user)
      case user.default_image_size
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
    def has_large?
      image_width > Danbooru.config.large_image_width
    end
    
    def large_image_width
      [Danbooru.config.large_image_width, image_width].min
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
      when "large"
        large_image_width
        
      else
        image_width
      end
    end
    
    def image_height_for(user)
      case user.default_image_size
      when "large"
        large_image_height
        
      else
        image_height
      end
    end
    
    def resize_percentage
      100 * large_image_width.to_f / image_width.to_f
    end
  end
  
  module ApprovalMethods
    def is_approvable?
      !is_status_locked? && (is_pending? || is_flagged? || is_deleted?) && approver_id != CurrentUser.id
    end
    
    def flag!(reason)
      if is_status_locked?
        raise PostFlag::Error.new("Post is locked and cannot be flagged")
      end
      
      flag = flags.create(:reason => reason, :is_resolved => false)
      
      if flag.errors.any?
        raise PostFlag::Error.new(flag.errors.full_messages.join("; "))
      end

      update_column(:is_flagged, true)
    end
    
    def appeal!(reason)
      if is_status_locked?
        raise PostAppeal::Error.new("Post is locked and cannot be appealed")
      end
      
      appeal = appeals.create(:reason => reason)
      
      if appeal.errors.any?
        raise PostAppeal::Error.new(appeal.errors.full_messages.join("; "))
      end
    end

    def approve!
      if is_status_locked?
        errors.add(:is_status_locked, "; post cannot be approved")
        raise ApprovalError.new("Post is locked and cannot be approved")
      end
      
      if uploader_id == CurrentUser.id
        errors.add(:base, "You cannot approve a post you uploaded")
        raise ApprovalError.new("You cannot approve a post you uploaded")
      end
      
      if approver_id == CurrentUser.id
        errors.add(:approver, "have already approved this post")
        raise ApprovalError.new("You have previously approved this post and cannot approve it again") 
      end
      
      flags.each {|x| x.resolve!}
      self.is_flagged = false
      self.is_pending = false
      self.is_deleted = false
      self.approver_id = CurrentUser.id
      save!
      ModAction.create(:description => "approved post ##{id}")
    end
    
    def disapproved_by?(user)
      PostDisapproval.where(:user_id => user.id, :post_id => id).exists?
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
    
    def normalized_source
      if source =~ /pixiv\.net\/img/
        img_id = source[/(\d+)(_s|_m|(_big)?_p\d+)?\.[\w\?]+\s*$/, 1]

        if $2 =~ /_p/
          "http://www.pixiv.net/member_illust.php?mode=manga&illust_id=#{img_id}"
        else
          "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{img_id}"
        end
      else
        source
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
      set_tag_string(tag_array.map {|x| Tag.find_or_create_by_name(x).name}.uniq.join(" "))
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
      normalized_tags = %w(tagme) if normalized_tags.empty?
      normalized_tags.sort!
      set_tag_string(normalized_tags.uniq.join(" "))
    end
    
    def filter_metatags(tags)
      metatags, tags = tags.partition {|x| x =~ /\A(?:-pool|pool|rating|fav|parent):/}
      apply_metatags(metatags)
      return tags
    end
    
    def apply_metatags(tags)
      tags.each do |tag|
        case tag
        when /^parent:none$/, /^parent:0$/
          self.parent_id = nil
          
        when /^parent:(\d+)$/
          self.parent_id = $1.to_i
        
        when /^-pool:(\d+)$/
          pool = Pool.find_by_id($1.to_i)
          remove_pool!(pool) if pool
          
        when /^-pool:(.+)$/
          pool = Pool.find_by_name($1)
          remove_pool!(pool) if pool
        
        when /^pool:(\d+)$/
          pool = Pool.find_by_id($1.to_i)
          add_pool!(pool) if pool
          
        when /^pool:(.+)$/
          pool = Pool.find_by_name($1)
          if pool.nil?
            pool = Pool.create(:name => $1, :description => "This pool was automatically generated")
          end
          add_pool!(pool) if pool

        when /^rating:([qse])/i
          self.rating = $1.downcase
          
        when /^fav:(.+)$/
          add_favorite!(CurrentUser.user)
        end
      end
    end
    
    def has_tag?(tag)
      tag_string =~ /(?:^| )#{tag}(?:$| )/
    end
    
    def tag_categories
      @tag_categories ||= Tag.categories_for(tag_array)
    end
    
    def copyright_tags
      typed_tags("copyright")
    end
    
    def character_tags
      typed_tags("character")
    end
    
    def artist_tags
      typed_tags("artist")
    end
    
    def typed_tags(name)
      @typed_tags ||= {}
      @typed_tags[name] ||= begin
        tag_array.select do |tag|
          tag_categories[tag] == Danbooru.config.tag_category_mapping[name]
        end
      end
    end
    
    def essential_tag_string
      tag_array.each do |tag|
        if tag_categories[tag] == Danbooru.config.tag_category_mapping["copyright"]
          return tag
        end
      end

      tag_array.each do |tag|
        if tag_categories[tag] == Danbooru.config.tag_category_mapping["character"]
          return tag
        end
      end

      tag_array.each do |tag|
        if tag_categories[tag] == Danbooru.config.tag_category_mapping["artist"]
          return tag
        end
      end

      return tag_array.first
    end
  end
  
  module FavoriteMethods
    def favorited_by?(user_id)
      fav_string =~ /(?:\A| )fav:#{user_id}(?:\Z| )/
    end
    
    def append_user_to_fav_string(user_id)
      update_column(:fav_string, (fav_string + " fav:#{user_id}").strip)
    end
    
    def add_favorite!(user)
      return if favorited_by?(user.id)
      append_user_to_fav_string(user.id)
      user.add_favorite!(self)
    end
    
    def delete_user_from_fav_string(user_id)
      update_column(:fav_string, fav_string.gsub(/(?:\A| )fav:#{user_id}(?:\Z| )/, " ").strip)
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
  
  module UploaderMethods
    def initialize_uploader
      if uploader_id.blank?
        self.uploader_id = CurrentUser.id
        self.uploader_ip_addr = CurrentUser.ip_addr
      end
    end
    
    def uploader_name
      User.id_to_name(uploader_id)
    end
  end
  
  module PoolMethods
    def pools
      @pools ||= begin
        pool_ids = pool_string.scan(/\d+/)
        Pool.where(["is_active = true and id in (?)", pool_ids])
      end
    end
    
    def belongs_to_pool?(pool)
      pool_string =~ /(?:\A| )pool:#{pool.id}(?:\Z| )/
    end
    
    def add_pool!(pool)
      return if belongs_to_pool?(pool)
      self.pool_string = "#{pool_string} pool:#{pool.id}".strip
      update_column(:pool_string, pool_string)
      pool.add!(self)
    end
    
    def remove_pool!(pool)
      return unless belongs_to_pool?(pool)
      self.pool_string = pool_string.gsub(/(?:\A| )pool:#{pool.id}(?:\Z| )/, " ").strip
      update_column(:pool_string, pool_string)
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
        raise PostVote::Error.new("You have already voted for this post")
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
    rescue ActiveRecord::StatementInvalid
      set_count_in_cache(tags, rand(24) * 1.hour)
      1_000_000
    rescue SearchError
      0
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
        return if post_id.nil?
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
      Post.update_has_children_flag_for(id)
      Post.update_has_children_flag_for(parent_id) if parent_id
      Post.update_has_children_flag_for(parent_id_was) if parent_id_was && parent_id != parent_id_was
    end
    
    def update_children_on_destroy
      if children.size == 0
        # do nothing
      elsif children.size == 1
        children.first.update_column(:parent_id, nil)
      else
        cached_children = children
        cached_children[0].update_column(:parent_id, nil)
        Post.update_all({:parent_id => cached_children[0].id}, :id => cached_children[1..-1].map(&:id))
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
    def annihilate!
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot delete post")
        return false
      end
      
      delete!
      destroy
    end
    
    def delete!
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot delete post")
        return false
      end
      
      Post.transaction do
        update_column(:is_deleted, true)
        give_favorites_to_parent
        update_children_on_destroy
        update_parent_on_destroy
        decrement_tag_post_counts
        update_column(:parent_id, nil)
        tag_array.each {|x| expire_cache(x)}
        ModAction.create(:description => "deleted post ##{id}")
      end
    end
    
    def undelete!
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot undelete post")
        return false
      end
      
      update_column(:is_deleted, false)
      tag_array.each {|x| expire_cache(x)}
      update_parent_on_save
      ModAction.create(:description => "undeleted post ##{id}")
    end
  end
  
  module VersionMethods
    def create_version
      CurrentUser.increment!(:post_update_count)
      
      if created_at == updated_at
        versions.create(
          :rating => rating,
          :source => source,
          :tags => tag_string,
          :parent_id => parent_id
        )
      elsif rating_changed? || source_changed? || parent_id_changed? || tag_string_changed?
        versions.create(
          :rating => rating,
          :source => source,
          :tags => tag_string,
          :parent_id => parent_id
        )
      end
    end
    
    def revert_to(target)
      self.tag_string = target.tags
      self.rating = target.rating
      self.source = target.source
      self.parent_id = target.parent_id
    end
    
    def revert_to!(target)
      revert_to(target)
      save!
    end
  end
  
  module NoteMethods
    def last_noted_at_as_integer
      last_noted_at.to_i
    end
  end
  
  module ApiMethods
    def hidden_attributes
      super + [:tag_index]
    end
    
    def serializable_hash(options = {})
      options ||= {}
      options[:except] ||= []
      options[:except] += hidden_attributes
      super(options)
    end
    
    def to_xml(options = {}, &block)
      # to_xml ignores the serializable_hash method
      options ||= {}
      options[:except] ||= []
      options[:except] += hidden_attributes
      super(options, &block)
    end
    
    def to_legacy_json
      return {
        "has_comments" => last_commented_at.present?,
        "parent_id" => parent_id,
        "status" => status,
        "has_children" => has_children?,
        "created_at" => created_at.to_formatted_s(:db),
        "md5" => md5,
        "has_notes" => last_noted_at.present?,
        "rating" => rating,
        "author" => uploader_name,
        "creator_id" => uploader_id,
        "width" => image_width,
        "source" => source,
        "preview_url" => preview_file_url,
        "score" => score,
        "tags" => tag_string,
        "height" => image_height,
        "file_size" => file_size,
        "id" => id,
        "file_url" => file_url
      }.to_json
    end
    
    def status
      if is_pending?
        "pending"
      elsif is_deleted?
        "deleted"
      elsif is_flagged?
        "flagged"
      else
        "active"
      end
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
  include VoteMethods
  extend CountMethods
  include CacheMethods
  include ParentMethods
  include DeletionMethods
  include VersionMethods
  include NoteMethods
  include ApiMethods
  
  def reload(options = nil)
    super
    reset_tag_array_cache
    @tag_categories = nil
    @typed_tags = nil
    self
  end
end

Post.connection.extend(PostgresExtensions)
