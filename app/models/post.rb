class Post < ActiveRecord::Base
  class ApprovalError < Exception ; end
  class DisapprovalError < Exception ; end
  class SearchError < Exception ; end

  attr_accessor :old_tag_string, :old_parent_id, :has_constraints, :disable_versioning
  after_destroy :delete_files
  after_destroy :delete_remote_files
  after_save :create_version
  after_save :update_parent_on_save
  after_save :apply_post_metatags, :on => :create
  before_save :merge_old_tags
  before_save :normalize_tags
  before_save :create_tags
  before_save :update_tag_post_counts
  before_save :set_tag_counts
  before_validation :initialize_uploader, :on => :create
  before_validation :parse_pixiv_id
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
  has_many :comments, :order => "comments.id", :dependent => :destroy
  has_many :children, :class_name => "Post", :foreign_key => "parent_id", :order => "posts.id"
  has_many :disapprovals, :class_name => "PostDisapproval", :dependent => :destroy
  validates_uniqueness_of :md5
  validates_presence_of :parent, :if => lambda {|rec| !rec.parent_id.nil?}
  validate :post_is_not_its_own_parent
  attr_accessible :source, :rating, :tag_string, :old_tag_string, :last_noted_at, :parent_id, :as => [:member, :builder, :gold, :platinum, :contributor, :janitor, :moderator, :admin, :default]
  attr_accessible :is_rating_locked, :is_note_locked, :as => [:builder, :contributor, :janitor, :moderator, :admin]
  attr_accessible :is_status_locked, :as => [:admin]

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
      "#{Danbooru.config.ssd_path}/public/data/preview/#{file_path_prefix}#{md5}.jpg"
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
      if !is_image?
        return "/images/download-preview.png"
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
      file_ext =~ /jpg|jpeg|gif|png/
    end

    def is_flash?
      file_ext =~ /swf/
    end
  end

  module ImageMethods
    def has_large?
      image_width.present? && image_width > Danbooru.config.large_image_width
    end

    def has_large
      has_large?
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

      update_column(:is_flagged, true) unless is_flagged?
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
    end

    def disapproved_by?(user)
      PostDisapproval.where(:user_id => user.id, :post_id => id).exists?
    end
  end

  module PresenterMethods
    def presenter
      @presenter ||= PostPresenter.new(self)
    end

    def status_flags
      flags = []
      flags << "pending" if is_pending?
      flags << "flagged" if is_flagged?
      flags << "deleted" if is_deleted?
      flags << "banned" if is_banned?
      flags.join(" ")
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
      set_tag_string(tag_array.map {|x| Tag.find_or_create_by_name(x).name}.uniq.sort.join(" "))
    end

    def increment_tag_post_counts
      Tag.update_all("post_count = post_count + 1", {:name => tag_array}) if tag_array.any?
    end

    def decrement_tag_post_counts
      Tag.update_all("post_count = post_count - 1", {:name => tag_array}) if tag_array.any?
    end

    def update_tag_post_counts
      decrement_tags = tag_array_was - tag_array
      increment_tags = tag_array - tag_array_was
      if increment_tags.any?
        Tag.update_all("post_count = post_count + 1", {:name => increment_tags})
        Post.expire_cache_for_all(increment_tags)
      end
      if decrement_tags.any?
        Tag.update_all("post_count = post_count - 1", {:name => decrement_tags})
        Post.expire_cache_for_all(decrement_tags)
      end
      Post.expire_cache_for_all([""]) if new_record? || id <= 100_000
    end

    def set_tag_counts
      self.tag_count = 0
      self.tag_count_general = 0
      self.tag_count_artist = 0
      self.tag_count_copyright = 0
      self.tag_count_character = 0

      categories = Tag.categories_for(tag_array, :disable_caching => true)
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
        set_tag_string(((current_tags + new_tags) - old_tags + (current_tags & new_tags)).uniq.sort.join(" "))
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
      normalized_tags = filter_metatags(normalized_tags)
      normalized_tags = normalized_tags.map{|tag| tag.downcase}
      normalized_tags = TagAlias.to_aliased(normalized_tags)
      normalized_tags = TagImplication.with_descendants(normalized_tags)
      normalized_tags = %w(tagme) if normalized_tags.empty?
      normalized_tags.sort!
      set_tag_string(normalized_tags.uniq.sort.join(" "))
    end

    def filter_metatags(tags)
      @pre_metatags, tags = tags.partition {|x| x =~ /\A(?:rating|parent):/i}
      @post_metatags, tags = tags.partition {|x| x =~ /\A(?:-pool|pool|fav):/i}
      apply_pre_metatags
      return tags
    end

    def apply_post_metatags
      return unless @post_metatags

      @post_metatags.each do |tag|
        case tag
        when /^-pool:(\d+)$/i
          pool = Pool.find_by_id($1.to_i)
          remove_pool!(pool) if pool

        when /^-pool:(.+)$/i
          pool = Pool.find_by_name($1)
          remove_pool!(pool) if pool

        when /^pool:(\d+)$/i
          pool = Pool.find_by_id($1.to_i)
          add_pool!(pool) if pool

        when /^pool:(.+)$/i
          pool = Pool.find_by_name($1)
          if pool.nil?
            pool = Pool.create(:name => $1, :description => "This pool was automatically generated")
          end
          add_pool!(pool) if pool

        when /^fav:(.+)$/i
          add_favorite!(CurrentUser.user)
        end
      end
    end

    def apply_pre_metatags
      return unless @pre_metatags

      @pre_metatags.each do |tag|
        case tag
        when /^parent:none$/i, /^parent:0$/i
          self.parent_id = nil

        when /^parent:(\d+)$/i
          if Post.exists?(["id = ? and is_deleted = false", $1.to_i])
            self.parent_id = $1.to_i
          end

        when /^rating:([qse])/i
          self.rating = $1.downcase
        end
      end
    end

    def has_tag?(tag)
      tag_string =~ /(?:^| )#{tag}(?:$| )/
    end

    def has_dup_tag?
      has_tag?("duplicate") ? true : false
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

    def artist_tags_excluding_hidden
      artist_tags - %w(banned_artist)
    end

    def general_tags
      typed_tags("general")
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

    def tag_string_copyright
      copyright_tags.join(" ")
    end

    def tag_string_character
      character_tags.join(" ")
    end

    def tag_string_artist
      artist_tags.join(" ")
    end

    def tag_string_general
      general_tags.join(" ")
    end
  end

  module FavoriteMethods
    def clean_fav_string?
      rand(100) < [Math.log(fav_string.size, 2), 5].min
    end

    def clean_fav_string!
      array = fav_string.scan(/\S+/).uniq
      self.fav_string = array.join(" ")
      self.fav_count = array.size
      update_column(:fav_string, fav_string)
      update_column(:fav_count, fav_count)
    end

    def favorited_by?(user_id)
      fav_string =~ /(?:\A| )fav:#{user_id}(?:\Z| )/
    end

    def append_user_to_fav_string(user_id)
      update_column(:fav_string, (fav_string + " fav:#{user_id}").strip)
      clean_fav_string! if clean_fav_string?
    end

    def add_favorite!(user)
      Favorite.add(self, user)
    end

    def delete_user_from_fav_string(user_id)
      update_column(:fav_string, fav_string.gsub(/(?:\A| )fav:#{user_id}(?:\Z| )/, " ").strip)
    end

    def remove_favorite!(user)
      Favorite.remove(self, user)
    end

    def favorited_user_ids
      fav_string.scan(/\d+/)
    end

    def favorited_users
      favorited_user_ids.map {|id| User.find_by_id(id)}
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
      User.id_to_name(uploader_id).tr("_", " ")
    end
  end

  module PoolMethods
    def pools
      @pools ||= begin
        pool_ids = pool_string.scan(/\d+/)
        Pool.where(["is_deleted = false and id in (?)", pool_ids])
      end
    end

    def belongs_to_pool?(pool)
      pool_string =~ /(?:\A| )pool:#{pool.id}(?:\Z| )/
    end

    def belongs_to_pool_with_id?(pool_id)
      pool_string =~ /(?:\A| )pool:#{pool_id}(?:\Z| )/
    end

    def add_pool!(pool)
      return if belongs_to_pool?(pool)
      return if pool.is_deleted?
      self.pool_string = "#{pool_string} pool:#{pool.id}".strip
      update_column(:pool_string, pool_string) unless new_record?
      pool.add!(self)
    end

    def remove_pool!(pool)
      return unless belongs_to_pool?(pool)
      return if pool.is_deleted?
      self.pool_string = pool_string.gsub(/(?:\A| )pool:#{pool.id}(?:\Z| )/, " ").strip
      update_column(:pool_string, pool_string) unless new_record?
      pool.remove!(self)
    end
  end

  module VoteMethods
    def can_be_voted_by?(user)
      !PostVote.exists?(:user_id => user.id, :post_id => id)
    end

    def vote!(score)
      if can_be_voted_by?(CurrentUser.user)
        if score == "up"
          Post.update_all("score = score + 1, up_score = up_score + 1", {:id => id})
        elsif score == "down"
          Post.update_all("score = score - 1, down_score = down_score - 1", {:id => id})
        end

        votes.create(:score => score)
      else
        raise PostVote::Error.new("You have already voted for this post")
      end
    end
  end

  module CountMethods
    def fix_post_counts
      post.set_tag_counts
      post.update_column(:tag_count, post.tag_count)
      post.update_column(:tag_count_general, post.tag_count_general)
      post.update_column(:tag_count_artist, post.tag_count_artist)
      post.update_column(:tag_count_copyright, post.tag_count_copyright)
      post.update_column(:tag_count_character, post.tag_count_character)
    end

    def get_count_from_cache(tags)
      count = Cache.get(count_cache_key(tags))

      if count.nil?
        count = select_value_sql("SELECT post_count FROM tags WHERE name = ?", tags.to_s)
      end

      count
    end

    def set_count_in_cache(tags, count, expiry = nil)
      if expiry.nil?
        if count < 100
          expiry = 1.minute
        else
          expiry = (count * 4).minutes
        end
      end

      Cache.put(count_cache_key(tags), count, expiry)
    end

    def count_cache_key(tags)
      "pfc:#{Cache.sanitize(tags)}"
    end

    def fast_count(tags = "")
      tags = tags.to_s.strip

      if tags.blank? && Danbooru.config.blank_tag_search_fast_count
        count = Danbooru.config.blank_tag_search_fast_count
      elsif tags =~ /^rating:\S+$/
        count = Danbooru.config.blank_tag_search_fast_count
      elsif tags =~ /(?:#{Tag::METATAGS}):/
        count = fast_count_search(tags)
      else
        count = get_count_from_cache(tags)

        if count.to_i == 0
          count = fast_count_search(tags)
        end
      end

      count.to_i
    rescue SearchError
      0
    end

    def fast_count_search(tags)
      count = Post.with_timeout(500, Danbooru.config.blank_tag_search_fast_count || 1_000_000) do
        Post.tag_match(tags).count
      end
      if count > 0
        set_count_in_cache(tags, count)
      end
      count
    end
  end

  module CacheMethods
    def expire_cache_for_all(tag_names)
      Danbooru.config.all_server_hosts.each do |host|
        delay(:queue => host).expire_cache(tag_names)
      end
    end

    def expire_cache(tag_names)
      tag_names.each do |tag_name|
        Cache.delete(Post.count_cache_key(tag_name))
      end
    end
  end

  module ParentMethods
    # A parent has many children. A child belongs to a parent.
    # A parent cannot have a parent.
    #
    # After expunging a child:
    # - Move favorites to parent.
    # - Does the parent have any active children?
    #   - Yes: Done.
    #   - No: Update parent's has_children flag to false.
    #
    # After expunging a parent:
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

      update_column(:score, 0)
    end

    def post_is_not_its_own_parent
      if parent_id.present? && id == parent_id
        errors[:base] << "Post cannot have itself as a parent"
        false
      end
    end
  end

  module DeletionMethods
    def expunge!
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot delete post")
        return false
      end

      ModAction.create(:description => "permanently deleted post ##{id}")
      delete!(:without_mod_action => true)
      give_favorites_to_parent
      update_children_on_destroy
      update_parent_on_destroy
      decrement_tag_post_counts
      destroy
    end

    def ban!
      update_column(:is_banned, true)
      ModAction.create(:description => "banned post ##{id}")
    end

    def unban!
      update_column(:is_banned, false)
      ModAction.create(:description => "unbanned post ##{id}")
    end

    def delete!(options = {})
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot delete post")
        return false
      end

      Post.transaction do
        update_column(:is_deleted, true)
        update_column(:is_pending, false)
        update_column(:is_flagged, false)
        update_column(:is_banned, true) if options[:ban] || has_tag?("banned_artist")

        unless options[:without_mod_action]
          ModAction.create(:description => "deleted post ##{id}")
        end
      end
    end

    def undelete!
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot undelete post")
        return false
      end

      self.is_deleted = false
      self.approver_id = CurrentUser.id
      save
      Post.expire_cache_for_all(tag_array)
      ModAction.create(:description => "undeleted post ##{id}")
    end
  end

  module VersionMethods
    def create_version
      return if disable_versioning

      if new_record? || rating_changed? || source_changed? || parent_id_changed? || tag_string_changed?
        CurrentUser.increment!(:post_update_count)
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

    def copy_notes_to(other_post)
      notes.each do |note|
        note.copy_to(other_post)
      end
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
      unless options[:builder]
        options[:methods] ||= []
        options[:methods] += [:uploader_name, :has_large, :tag_string_artist, :tag_string_character, :tag_string_copyright, :tag_string_general]
      end
      hash = super(options)
      hash
    end

    def to_xml(options = {}, &block)
      options ||= {}
      options[:procs] ||= []
      options[:procs] << lambda {|options, record| options[:builder].tag!("uploader-name", record.uploader_name)}
      options[:procs] << lambda {|options, record| options[:builder].tag!("has-large", record.has_large?, :type => "boolean")}
      options[:procs] << lambda {|options, record| options[:builder].tag!("tag-string-artist", record.tag_string_artist)}
      options[:procs] << lambda {|options, record| options[:builder].tag!("tag-string-character", record.tag_string_character)}
      options[:procs] << lambda {|options, record| options[:builder].tag!("tag-string-copyright", record.tag_string_copyright)}
      options[:procs] << lambda {|options, record| options[:builder].tag!("tag-string-general", record.tag_string_general)}
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

  module SearchMethods
    def pending
      where("is_pending = ?", true)
    end

    def flagged
      where("is_flagged = ?", true)
    end

    def pending_or_flagged
      where("(is_pending = ? or (is_flagged = ? and id in (select _.post_id from post_flags _ where _.created_at >= ?)))", true, true, 1.week.ago)
    end

    def undeleted
      where("is_deleted = ?", false)
    end

    def deleted
      where("is_deleted = ?", true)
    end

    def visible(user)
      Danbooru.config.can_user_see_post_conditions(user)
    end

    def commented_before(date)
      where("last_commented_at < ?", date).order("last_commented_at DESC")
    end

    def has_notes
      where("last_noted_at is not null")
    end

    def for_user(user_id)
      where("uploader_id = ?", user_id)
    end

    def available_for_moderation(hidden)
      if hidden.present?
        where("posts.id IN (SELECT pd.post_id FROM post_disapprovals pd WHERE pd.user_id = ?)", CurrentUser.id)
      else
        where("posts.id NOT IN (SELECT pd.post_id FROM post_disapprovals pd WHERE pd.user_id = ?)", CurrentUser.id)
      end
    end

    def hidden_from_moderation
      where("id IN (SELECT pd.post_id FROM post_disapprovals pd WHERE pd.user_id = ?)", CurrentUser.id)
    end

    def raw_tag_match(tag)
      where("posts.tag_index @@ to_tsquery('danbooru', E?)", tag.to_escaped_for_tsquery)
    end

    def tag_match(query)
      PostQueryBuilder.new(query).build
    end

    def positive
      where("score > 1")
    end

    def negative
      where("score < -1")
    end

    def updater_name_matches(name)
      where("updater_id = (select _.id from users _ where lower(_.name) = ?)", name.mb_chars.downcase)
    end

    def after_id(num)
      if num.present?
        where("id > ?", num.to_i).reorder("id asc")
      else
        where("true")
      end
    end

    def before_id(num)
      if num.present?
        where("id < ?", num.to_i).reorder("id desc")
      else
        where("true")
      end
    end

    def search(params)
      q = scoped
      return q if params.blank?

      if params[:before_id].present?
        q = q.before_id(params[:before_id].to_i)
      end

      if params[:after_id].present?
        q = q.after_id(params[:after_id].to_i)
      end

      if params[:tag_match].present?
        q = q.tag_match(params[:tag_match])
      end

      q
    end
  end
  
  module PixivMethods
    def parse_pixiv_id
      if source =~ %r!http://i\d\.pixiv\.net/img-inf/img/\d+/\d+/\d+/\d+/\d+/\d+/(\d+)_s.jpg!
        self.pixiv_id = $1
      elsif source =~ %r!http://img\d+\.pixiv\.net/img/[^\/]+/(\d+)!
        self.pixiv_id = $1
      elsif source =~ %r!http://i\d\.pixiv\.net/img\d+/img/[^\/]+/(\d+)!
        self.pixiv_id = $1
      elsif source =~ /pixiv\.net/ && source =~ /illust_id=(\d+)/
        self.pixiv_id = $1
      else
        self.pixiv_id = nil
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
  extend CacheMethods
  include ParentMethods
  include DeletionMethods
  include VersionMethods
  include NoteMethods
  include ApiMethods
  extend SearchMethods
  include PixivMethods

  def reload(options = nil)
    super
    reset_tag_array_cache
    @tag_categories = nil
    @typed_tags = nil
    self
  end
end

Post.connection.extend(PostgresExtensions)
