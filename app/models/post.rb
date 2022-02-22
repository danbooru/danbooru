# frozen_string_literal: true

class Post < ApplicationRecord
  class RevertError < StandardError; end
  class DeletionError < StandardError; end

  # Tags to copy when copying notes.
  NOTE_COPY_TAGS = %w[translated partially_translated check_translation translation_request reverse_translation
                      annotated partially_annotated check_annotation annotation_request]

  RESTRICTED_TAGS_REGEX = /(?:^| )(?:#{Danbooru.config.restricted_tags.join("|")})(?:$| )/o

  deletable

  normalize :source, :normalize_source
  before_validation :merge_old_changes
  before_validation :normalize_tags
  before_validation :parse_pixiv_id
  before_validation :blank_out_nonexistent_parents
  before_validation :remove_parent_loops
  validates :md5, uniqueness: { message: ->(post, _data) { "Duplicate of post ##{Post.find_by_md5(post.md5).id}" }}, on: :create
  validates :rating, presence: { message: "not selected" }
  validates :rating, inclusion: { in: %w[s q e], message: "must be S, Q, or E" }, if: -> { rating.present? }
  validates :source, length: { maximum: 1200 }
  validate :added_tags_are_valid
  validate :removed_tags_are_valid
  validate :has_artist_tag
  validate :has_copyright_tag
  validate :has_enough_tags
  validate :post_is_not_its_own_parent
  validate :uploader_is_not_limited, on: :create
  before_save :update_tag_post_counts
  before_save :update_tag_category_counts
  before_create :autoban
  after_save :create_version
  after_save :update_parent_on_save
  after_save :apply_post_metatags
  after_create_commit :update_iqdb

  belongs_to :approver, class_name: "User", optional: true
  belongs_to :uploader, :class_name => "User", :counter_cache => "post_upload_count"
  belongs_to :parent, class_name: "Post", optional: true
  has_one :media_asset, -> { active }, foreign_key: :md5, primary_key: :md5
  has_one :artist_commentary, :dependent => :destroy
  has_one :pixiv_ugoira_frame_data, class_name: "PixivUgoiraFrameData", foreign_key: :md5, primary_key: :md5
  has_one :vote_by_current_user, -> { active.where(user_id: CurrentUser.id) }, class_name: "PostVote" # XXX using current user here is wrong
  has_many :flags, :class_name => "PostFlag", :dependent => :destroy
  has_many :appeals, :class_name => "PostAppeal", :dependent => :destroy
  has_many :votes, :class_name => "PostVote", :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :children, -> {order("posts.id")}, :class_name => "Post", :foreign_key => "parent_id"
  has_many :approvals, :class_name => "PostApproval", :dependent => :destroy
  has_many :disapprovals, :class_name => "PostDisapproval", :dependent => :destroy
  has_many :favorites, dependent: :destroy
  has_many :replacements, class_name: "PostReplacement", :dependent => :destroy

  attr_accessor :old_tag_string, :old_parent_id, :old_source, :old_rating, :has_constraints, :disable_versioning

  scope :pending, -> { where(is_pending: true) }
  scope :flagged, -> { where(is_flagged: true) }
  scope :banned, -> { where(is_banned: true) }
  # XXX conflict with deletable
  scope :active, -> { where(is_pending: false, is_deleted: false, is_flagged: false).where.not(id: PostAppeal.pending) }
  scope :appealed, -> { deleted.where(id: PostAppeal.pending.select(:post_id)) }
  scope :in_modqueue, -> { pending.or(flagged).or(appealed) }
  scope :expired, -> { pending.where("posts.created_at < ?", Danbooru.config.moderation_period.ago) }

  scope :unflagged, -> { where(is_flagged: false) }
  scope :has_notes, -> { where.not(last_noted_at: nil) }
  scope :for_user, ->(user_id) { where(uploader_id: user_id) }

  if PostVersion.enabled?
    has_many :versions, -> { Rails.env.test? ? order("post_versions.updated_at ASC, post_versions.id ASC") : order("post_versions.updated_at ASC") }, class_name: "PostVersion", dependent: :destroy
  end

  def self.new_from_upload(upload_media_asset, tag_string: nil, rating: nil, parent_id: nil, source: nil, artist_commentary_title: nil, artist_commentary_desc: nil, translated_commentary_title: nil, translated_commentary_desc: nil, is_pending: nil, add_artist_tag: false)
    upload = upload_media_asset.upload
    media_asset = upload_media_asset.media_asset

    # XXX depends on CurrentUser
    commentary = ArtistCommentary.new(
      original_title: artist_commentary_title,
      original_description: artist_commentary_desc,
      translated_title: translated_commentary_title,
      translated_description: translated_commentary_desc,
    )

    if add_artist_tag
      tag_string = "#{tag_string} #{upload_media_asset.source_strategy&.artists.to_a.map(&:tag).map(&:name).join(" ")}".strip
      tag_string += " " if tag_string.present?
    end

    post = Post.new(
      uploader: upload.uploader,
      uploader_ip_addr: upload.uploader_ip_addr,
      md5: media_asset&.md5,
      file_ext: media_asset&.file_ext,
      file_size: media_asset&.file_size,
      image_width: media_asset&.image_width,
      image_height: media_asset&.image_height,
      source: source.to_s,
      tag_string: tag_string,
      rating: rating,
      parent_id: parent_id,
      is_pending: !upload.uploader.can_upload_free? || is_pending.to_s.truthy?,
      artist_commentary: (commentary if commentary.any_field_present?),
    )
  end

  module FileMethods
    extend ActiveSupport::Concern

    def seo_tags
      presenter.humanized_essential_tag_string.gsub(/[^a-z0-9]+/, "_").gsub(/(?:^_+)|(?:_+$)/, "").gsub(/_{2,}/, "_")
    end

    def file(type = :original)
      media_asset.variant(type).open_file
    end

    def tagged_file_url(tagged_filenames: !CurrentUser.user.disable_tagged_filenames?)
      slug = seo_tags if tagged_filenames
      media_asset.variant(:original).file_url(slug)
    end

    def tagged_large_file_url(tagged_filenames: !CurrentUser.user.disable_tagged_filenames?)
      slug = seo_tags if tagged_filenames

      if media_asset.has_variant?(:sample)
        media_asset.variant(:sample).file_url(slug)
      else
        media_asset.variant(:original).file_url(slug)
      end
    end

    def file_url
      media_asset.variant(:original).file_url
    end

    def large_file_url
      if media_asset.has_variant?(:sample)
        media_asset.variant(:sample).file_url
      else
        media_asset.variant(:original).file_url
      end
    end

    def preview_file_url
      media_asset.variant(:preview).file_url
    end

    def open_graph_image_url
      if is_image?
        if has_large?
          large_file_url
        else
          file_url
        end
      else
        preview_file_url
      end
    end

    def file_url_for(user)
      if user.default_image_size == "large" && image_width > Danbooru.config.large_image_width
        tagged_large_file_url
      else
        tagged_file_url
      end
    end

    def is_image?
      file_ext =~ /jpg|gif|png/i
    end

    def is_flash?
      file_ext =~ /swf/i
    end

    def is_video?
      file_ext.in?(%w[webm mp4])
    end

    def is_ugoira?
      file_ext =~ /zip/i
    end

    def has_preview?
      is_image? || is_video? || is_ugoira?
    end
  end

  module ImageMethods
    def twitter_card_supported?
      image_width.to_i >= 280 && image_height.to_i >= 150
    end

    def has_large?
      return false if has_tag?("animated_gif|animated_png")
      return true if is_ugoira?
      is_image? && image_width.present? && image_width > Danbooru.config.large_image_width
    end

    alias has_large has_large?

    def large_image_width
      if has_large?
        [Danbooru.config.large_image_width, image_width.to_i].min
      else
        image_width.to_i
      end
    end

    def large_image_height
      ratio = Danbooru.config.large_image_width.to_f / image_width.to_f
      if has_large? && ratio < 1
        (image_height * ratio).to_i
      else
        image_height
      end
    end

    def image_width_for(user)
      if user.default_image_size == "large"
        large_image_width
      else
        image_width
      end
    end

    def image_height_for(user)
      if user.default_image_size == "large"
        large_image_height
      else
        image_height
      end
    end

    def resize_percentage
      return 100 if image_width.to_i == 0
      100 * large_image_width.to_f / image_width.to_f
    end

    # XXX
    def current_image_size
      has_large? && CurrentUser.default_image_size == "large" ? "large" : "original"
    end
  end

  module ApprovalMethods
    def in_modqueue?
      is_pending? || is_flagged? || is_appealed?
    end

    def is_active?
      !is_deleted? && !in_modqueue?
    end

    def is_appealed?
      is_deleted? && appeals.any?(&:pending?)
    end

    def is_appealable?
      is_deleted? && !is_appealed?
    end

    def is_approvable?(user = CurrentUser.user)
      !is_active? && uploader != user
    end

    def disapproved_by?(user)
      PostDisapproval.exists?(user_id: user.id, post_id: id)
    end

    def autoban
      if has_tag?("banned_artist") || has_tag?("paid_reward")
        self.is_banned = true
      end
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
      Sources::Strategies.normalize_source(source)
    end

    def source_domain
      return "" unless source =~ %r{\Ahttps?://}i

      Danbooru::URL.parse(normalized_source)&.domain.to_s
    end
  end

  module TagMethods
    def tag_array
      tag_string.split
    end

    def tag_array_was
      (tag_string_in_database.presence || tag_string_before_last_save || "").split
    end

    def tags
      Tag.where(name: tag_array)
    end

    def tags_was
      Tag.where(name: tag_array_was)
    end

    def added_tags
      tags - tags_was
    end

    def decrement_tag_post_counts
      Tag.where(:name => tag_array).update_all("post_count = post_count - 1") if tag_array.any?
    end

    def update_tag_post_counts
      decrement_tags = tag_array_was - tag_array

      increment_tags = tag_array - tag_array_was
      if increment_tags.any?
        Tag.increment_post_counts(increment_tags)
      end
      if decrement_tags.any?
        Tag.decrement_post_counts(decrement_tags)
      end
    end

    # Update tag_count_general, tag_count_copyright, etc.
    def update_tag_category_counts
      TagCategory.categories.each do |category_name|
        tag_count = tags.select { |t| t.category_name.downcase == category_name }.size
        send("tag_count_#{category_name}=", tag_count)
      end

      self.tag_count = tag_array.size
    end

    def merge_old_changes
      @removed_tags = []

      if old_tag_string
        # If someone else committed changes to this post before we did,
        # then try to merge the tag changes together.
        current_tags = tag_string_was.split
        new_tags = PostQueryBuilder.new(tag_string).parse_tag_edit
        old_tags = old_tag_string.split

        kept_tags = current_tags & new_tags
        @removed_tags = old_tags - kept_tags

        self.tag_string = ((current_tags + new_tags) - old_tags + (current_tags & new_tags)).uniq.sort.join(" ")
      end

      if old_parent_id == ""
        old_parent_id = nil
      else
        old_parent_id = old_parent_id.to_i
      end
      if old_parent_id == parent_id
        self.parent_id = parent_id_before_last_save || parent_id_was
      end

      if old_source == source.to_s
        self.source = source_before_last_save || source_was
      end

      if old_rating == rating
        self.rating = rating_before_last_save || rating_was
      end
    end

    def normalize_tags
      normalized_tags = PostQueryBuilder.new(tag_string).parse_tag_edit
      normalized_tags = apply_casesensitive_metatags(normalized_tags)
      normalized_tags = normalized_tags.map(&:downcase)
      normalized_tags = filter_metatags(normalized_tags)
      normalized_tags = TagAlias.to_aliased(normalized_tags)
      normalized_tags = remove_negated_tags(normalized_tags)
      normalized_tags = add_automatic_tags(normalized_tags)
      normalized_tags = remove_invalid_tags(normalized_tags)
      normalized_tags = Tag.convert_cosplay_tags(normalized_tags)
      normalized_tags += Tag.create_for_list(Tag.automatic_tags_for(normalized_tags))
      normalized_tags += TagImplication.tags_implied_by(normalized_tags).map(&:name)
      normalized_tags = normalized_tags.compact.uniq.sort
      normalized_tags = Tag.create_for_list(normalized_tags)
      self.tag_string = normalized_tags.join(" ")
    end

    def remove_invalid_tags(tag_names)
      invalid_tags = tag_names.map { |name| Tag.new(name: name) }.select { |tag| tag.invalid?(:name) }

      invalid_tags.each do |tag|
        tag.errors.messages.each do |_attribute, messages|
          warnings.add(:base, "Couldn't add tag: #{messages.join(';')}")
        end
      end

      tag_names - invalid_tags.map(&:name)
    end

    def remove_negated_tags(tags)
      @negated_tags, tags = tags.partition {|x| x =~ /\A-/i}
      @negated_tags = @negated_tags.map {|x| x[1..-1]}
      @negated_tags = TagAlias.to_aliased(@negated_tags)
      tags - @negated_tags
    end

    def add_automatic_tags(tags)
      tags -= %w[incredibly_absurdres absurdres highres lowres flash video ugoira animated_gif animated_png exif_rotation non-repeating_animation non-web_source]

      if tags.size >= 30
        tags -= ["tagme"]
      elsif tags.empty?
        tags << "tagme"
      end

      if image_width >= 10_000 || image_height >= 10_000
        tags << "incredibly_absurdres"
      end
      if image_width >= 3200 || image_height >= 2400
        tags << "absurdres"
      end
      if image_width >= 1600 || image_height >= 1200
        tags << "highres"
      end
      if image_width <= 500 && image_height <= 500
        tags << "lowres"
      end

      if image_width >= 1024 && image_width.to_f / image_height >= 4
        tags << "wide_image"
      elsif image_height >= 1024 && image_height.to_f / image_width >= 4
        tags << "tall_image"
      end

      if is_flash?
        tags << "flash"
      end

      if is_video?
        tags << "video"
      end

      if is_ugoira?
        tags << "ugoira"
      end

      if source.present? && source !~ %r{\Ahttps?://}i
        tags << "non-web_source"
      end

      # Allow only Flash files to be manually tagged as `animated`; GIFs, PNGs, videos, and ugoiras are automatically tagged.
      tags -= ["animated"] unless is_flash?
      tags << "animated" if media_asset.is_animated?
      tags << "animated_gif" if media_asset.is_animated_gif?
      tags << "animated_png" if media_asset.is_animated_png?

      tags << "greyscale" if media_asset.is_greyscale?
      tags << "exif_rotation" if media_asset.is_rotated?
      tags << "non-repeating_animation" if media_asset.is_non_repeating_animation?

      tags
    end

    def apply_casesensitive_metatags(tags)
      casesensitive_metatags, tags = tags.partition {|x| x =~ /\A(?:source):/i}
      # Reuse the following metatags after the post has been saved
      casesensitive_metatags += tags.select {|x| x =~ /\A(?:newpool):/i}
      if !casesensitive_metatags.empty?
        case casesensitive_metatags[-1]
        when /^source:none$/i
          self.source = ""

        when /^source:"(.*)"$/i
          self.source = $1

        when /^source:(.*)$/i
          self.source = $1

        when /^newpool:(.+)$/i
          pool = Pool.find_by_name($1)
          if pool.nil?
            Pool.create(name: $1, description: "This pool was automatically generated")
          end
        end
      end

      tags
    end

    def filter_metatags(tags)
      @pre_metatags, tags = tags.partition {|x| x =~ /\A(?:rating|parent|-parent):/i}
      tags = apply_categorization_metatags(tags)
      @post_metatags, tags = tags.partition {|x| x =~ /\A(?:-pool|pool|newpool|fav|-fav|child|-child|-favgroup|favgroup|upvote|downvote|status|-status|disapproved):/i}
      apply_pre_metatags
      tags
    end

    def apply_categorization_metatags(tags)
      tags.map do |x|
        if x =~ Tag.categories.regexp
          tag = Tag.find_or_create_by_name(x)
          tag.name
        else
          x
        end
      end
    end

    def apply_post_metatags
      return unless @post_metatags

      @post_metatags.each do |tag|
        case tag
        when /^-pool:(\d+)$/i
          pool = Pool.find_by_id($1.to_i)
          pool&.remove!(self)

        when /^-pool:(.+)$/i
          pool = Pool.find_by_name($1)
          pool&.remove!(self)

        when /^pool:(\d+)$/i
          pool = Pool.find_by_id($1.to_i)
          pool&.add!(self)

        when /^pool:(.+)$/i
          pool = Pool.find_by_name($1)
          pool&.add!(self)

        when /^newpool:(.+)$/i
          pool = Pool.find_by_name($1)
          pool&.add!(self)

        when /^fav:(.+)$/i
          raise User::PrivilegeError unless Pundit.policy!(CurrentUser.user, Favorite).create?
          Favorite.create(post: self, user: CurrentUser.user)

        when /^-fav:(.+)$/i
          raise User::PrivilegeError unless Pundit.policy!(CurrentUser.user, Favorite).create?
          Favorite.destroy_by(post: self, user: CurrentUser.user)

        when /^(up|down)vote:(.+)$/i
          score = ($1 == "up" ? 1 : -1)
          vote!(score, CurrentUser.user)

        when /^status:active$/i
          raise User::PrivilegeError unless CurrentUser.is_approver?
          approvals.create!(user: CurrentUser.user)

        when /^status:banned$/i
          raise User::PrivilegeError unless CurrentUser.is_approver?
          ban!

        when /^-status:banned$/i
          raise User::PrivilegeError unless CurrentUser.is_approver?
          unban!

        when /^disapproved:(.+)$/i
          raise User::PrivilegeError unless CurrentUser.is_approver?
          disapprovals.create!(user: CurrentUser.user, reason: $1.downcase)

        when /^child:none$/i
          children.each do |post|
            post.update!(parent_id: nil)
          end

        when /^-child:(.+)$/i
          children.search(id: $1).each do |post|
            post.update!(parent_id: nil)
          end

        when /^child:(.+)$/i
          Post.search(id: $1).where.not(id: id).limit(10).each do |post|
            post.update!(parent_id: id)
          end

        when /^-favgroup:(.+)$/i
          favgroup = FavoriteGroup.find_by_name_or_id!($1, CurrentUser.user)
          raise User::PrivilegeError unless Pundit.policy!(CurrentUser.user, favgroup).update?
          favgroup&.remove!(self)

        when /^favgroup:(.+)$/i
          favgroup = FavoriteGroup.find_by_name_or_id!($1, CurrentUser.user)
          raise User::PrivilegeError unless Pundit.policy!(CurrentUser.user, favgroup).update?
          favgroup&.add!(self)

        end
      end
    end

    def apply_pre_metatags
      return unless @pre_metatags

      @pre_metatags.each do |tag|
        case tag
        when /^parent:none$/i, /^parent:0$/i
          self.parent_id = nil

        when /^-parent:(\d+)$/i
          if parent_id == $1.to_i
            self.parent_id = nil
          end

        when /^parent:(\d+)$/i
          if $1.to_i != id && Post.exists?(["id = ?", $1.to_i])
            self.parent_id = $1.to_i
            remove_parent_loops
          end

        when /^rating:([qse])/i
          self.rating = $1

        end
      end
    end

    def has_tag?(tag)
      tag_string.match?(/(?:^| )(?:#{tag})(?:$| )/)
    end

    def add_tag(tag)
      self.tag_string = "#{tag_string} #{tag}"
    end

    def remove_tag(tag)
      self.tag_string = (tag_array - Array(tag)).join(" ")
    end

    def tag_categories
      @tag_categories ||= Tag.categories_for(tag_array)
    end

    def typed_tags(name)
      @typed_tags ||= {}
      @typed_tags[name] ||= begin
        tag_array.select do |tag|
          tag_categories[tag] == TagCategory.mapping[name]
        end
      end
    end

    TagCategory.categories.each do |category|
      define_method("tag_string_#{category}") do
        typed_tags(category).join(" ")
      end
    end
  end

  module FavoriteMethods
    def favorited_by?(user)
      return false if user.is_anonymous?
      Favorite.exists?(post: self, user: user)
    end

    def favorite_groups
      FavoriteGroup.for_post(id)
    end

    def remove_from_fav_groups
      FavoriteGroup.for_post(id).find_each do |favgroup|
        favgroup.remove!(self)
      end
    end
  end

  module PoolMethods
    def pools
      Pool.where("pools.post_ids && array[?]", id)
    end

    def has_active_pools?
      pools.undeleted.present?
    end

    def remove_from_all_pools
      pools.find_each do |pool|
        pool.remove!(self)
      end
    end
  end

  module VoteMethods
    def vote!(score, voter)
      # Ignore vote if user doesn't have permission to vote.
      return unless Pundit.policy!(voter, PostVote).create?

      with_lock do
        votes.create!(user: voter, score: score) unless votes.active.exists?(user: voter, score: score)
        reload # PostVote.create modifies our score. Reload to get the new score.
      end
    end
  end

  module ParentMethods
    # A parent has many children. A child belongs to a parent.
    # A parent cannot have a parent.
    #
    # After expunging a child:
    # - Move favorites to parent.
    # - Does the parent have any children?
    #   - Yes: Done.
    #   - No: Update parent's has_children flag to false.
    #
    # After expunging a parent:
    # - Move favorites to the first child.
    # - Reparent all children to the first child.

    def update_has_children_flag
      update(has_children: children.exists?, has_active_children: children.undeleted.exists?)
    end

    def blank_out_nonexistent_parents
      if parent_id.present? && parent.nil?
        self.parent_id = nil
      end
    end

    def remove_parent_loops
      if parent.present? && parent.parent_id.present? && parent.parent_id == id
        parent.parent_id = nil
        parent.save
      end
    end

    def update_parent_on_destroy
      parent&.update_has_children_flag
    end

    def update_children_on_destroy
      children.update(parent: nil)
    end

    def update_parent_on_save
      return unless saved_change_to_parent_id? || saved_change_to_is_deleted?

      parent.update_has_children_flag if parent.present?
      Post.find(parent_id_before_last_save).update_has_children_flag if parent_id_before_last_save.present?
    end

    def give_favorites_to_parent
      return if parent.nil?

      transaction do
        favorites.each do |fav|
          fav.destroy!
          Favorite.create(post: parent, user: fav.user)
        end
      end

      ModAction.log("moved favorites from post ##{id} to post ##{parent.id}", :post_move_favorites)
    end

    def has_visible_children?
      return true if has_active_children?
      return true if has_children? && CurrentUser.user.show_deleted_children?
      return true if has_children? && is_deleted?
      return false
    end

    def has_visible_children
      has_visible_children?
    end
  end

  module DeletionMethods
    def expunge!
      transaction do
        Post.without_timeout do
          ModAction.log("permanently deleted post ##{id} (md5=#{md5})", :post_permanent_delete)

          update_children_on_destroy
          decrement_tag_post_counts
          remove_from_all_pools
          remove_from_fav_groups
          media_asset.expunge!
          destroy
          update_parent_on_destroy
        end
      end

      remove_iqdb # this is non-transactional
    end

    def ban!
      update_column(:is_banned, true)
      ModAction.log("banned post ##{id}", :post_ban)
    end

    def unban!
      update_column(:is_banned, false)
      ModAction.log("unbanned post ##{id}", :post_unban)
    end

    def delete!(reason, move_favorites: false, user: CurrentUser.user)
      transaction do
        automated = (user == User.system)

        flags.pending.update!(status: :succeeded)
        appeals.pending.update!(status: :rejected)

        flags.create!(reason: reason, is_deletion: true, creator: user, status: :succeeded)
        update!(is_deleted: true, is_pending: false, is_flagged: false)

        # XXX This must happen *after* the `is_deleted` flag is set to true (issue #3419).
        give_favorites_to_parent if move_favorites

        uploader.upload_limit.update_limit!(is_pending?, false)

        unless automated
          ModAction.log("deleted post ##{id}, reason: #{reason}", :post_delete)
        end
      end
    end
  end

  module VersionMethods
    def create_version(force = false)
      if new_record? || saved_change_to_watched_attributes? || force
        create_new_version
      end
    end

    def saved_change_to_watched_attributes?
      saved_change_to_rating? || saved_change_to_source? || saved_change_to_parent_id? || saved_change_to_tag_string?
    end

    def merge_version?
      prev = versions.last
      prev && prev.updater_id == CurrentUser.user.id && prev.updated_at > 1.hour.ago
    end

    def create_new_version
      User.where(id: CurrentUser.id).update_all("post_update_count = post_update_count + 1")
      PostVersion.queue(self) if PostVersion.enabled?
    end

    def revert_to(target)
      if id != target.post_id
        raise RevertError, "You cannot revert to a previous version of another post."
      end

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
    def has_notes?
      last_noted_at.present?
    end

    def copy_notes_to(other_post, copy_tags: NOTE_COPY_TAGS)
      transaction do
        if id == other_post.id
          errors.add(:base, "Source and destination posts are the same")
          return false
        end
        unless has_notes?
          errors.add(:post, "has no notes")
          return false
        end

        notes.active.each do |note|
          note.copy_to(other_post)
        end

        dummy = Note.new
        if notes.active.length == 1
          dummy.body = "Copied 1 note from post ##{id}."
        else
          dummy.body = "Copied #{notes.active.length} notes from post ##{id}."
        end
        dummy.is_active = false
        dummy.post_id = other_post.id
        dummy.x = dummy.y = dummy.width = dummy.height = 0
        dummy.save

        copy_tags.each do |tag|
          other_post.remove_tag(tag)
          other_post.add_tag(tag) if has_tag?(tag)
        end

        other_post.has_embedded_notes = has_embedded_notes
        other_post.save
      end
    end
  end

  module ApiMethods
    def legacy_attributes
      hash = {
        "has_comments" => last_commented_at.present?,
        "parent_id" => parent_id,
        "status" => status,
        "has_children" => has_children?,
        "created_at" => created_at.to_formatted_s(:db),
        "has_notes" => has_notes?,
        "rating" => rating,
        "author" => uploader.name,
        "creator_id" => uploader_id,
        "width" => image_width,
        "source" => source,
        "score" => score,
        "tags" => tag_string,
        "height" => image_height,
        "file_size" => file_size,
        "id" => id,
      }

      if visible?
        hash["file_url"] = file_url
        hash["preview_url"] = preview_file_url
        hash["md5"] = md5
      end

      hash
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
    # Return a set of up to N random posts. May return less if there aren't
    # enough posts.
    #
    # @param n [Integer] The maximum number of posts to return
    # @return [ActiveRecord::Relation<Post>]
    def random(n = 1)
      posts = n.times.map do
        key = SecureRandom.hex(16)
        random_up(key) || random_down(key)
      end.compact.uniq

      reorder(nil).in_order_of(:id, posts.map(&:id))
    end

    def random_up(key)
      where("md5 < ?", key).reorder("md5 desc").first
    end

    def random_down(key)
      where("md5 >= ?", key).reorder("md5 asc").first
    end

    def sample(query, sample_size)
      user_tag_match(query, safe_mode: false, hide_deleted_posts: false).reorder(:md5).limit(sample_size)
    end

    # unflattens the tag_string into one tag per row.
    def with_unflattened_tags
      joins("CROSS JOIN unnest(string_to_array(tag_string, ' ')) AS tag")
    end

    def with_comment_stats
      relation = left_outer_joins(:comments).group(:id).select("posts.*")
      relation = relation.select("COUNT(comments.id) AS comment_count")
      relation = relation.select("COUNT(comments.id) FILTER (WHERE comments.is_deleted = TRUE)  AS deleted_comment_count")
      relation = relation.select("COUNT(comments.id) FILTER (WHERE comments.is_deleted = FALSE) AS active_comment_count")
      relation
    end

    def with_note_stats
      relation = left_outer_joins(:notes).group(:id).select("posts.*")
      relation = relation.select("COUNT(notes.id) AS note_count")
      relation = relation.select("COUNT(notes.id) FILTER (WHERE notes.is_active = TRUE)  AS active_note_count")
      relation = relation.select("COUNT(notes.id) FILTER (WHERE notes.is_active = FALSE) AS deleted_note_count")
      relation
    end

    def with_flag_stats
      relation = left_outer_joins(:flags).group(:id).select("posts.*")
      relation.select("COUNT(post_flags.id) AS flag_count")
    end

    def with_appeal_stats
      relation = left_outer_joins(:appeals).group(:id).select("posts.*")
      relation = relation.select("COUNT(post_appeals.id) AS appeal_count")
      relation
    end

    def with_approval_stats
      relation = left_outer_joins(:approvals).group(:id).select("posts.*")
      relation = relation.select("COUNT(post_approvals.id) AS approval_count")
      relation
    end

    def with_replacement_stats
      relation = left_outer_joins(:replacements).group(:id).select("posts.*")
      relation = relation.select("COUNT(post_replacements.id) AS replacement_count")
      relation
    end

    def with_child_stats
      relation = left_outer_joins(:children).group(:id).select("posts.*")
      relation = relation.select("COUNT(children_posts.id) AS child_count")
      relation = relation.select("COUNT(children_posts.id) FILTER (WHERE children_posts.is_deleted = TRUE)  AS deleted_child_count")
      relation = relation.select("COUNT(children_posts.id) FILTER (WHERE children_posts.is_deleted = FALSE) AS active_child_count")
      relation
    end

    def with_pool_stats
      pool_posts = Pool.joins("CROSS JOIN unnest(post_ids) AS post_id").select(:id, :is_deleted, :category, "post_id")
      relation = joins("LEFT OUTER JOIN (#{pool_posts.to_sql}) pools ON pools.post_id = posts.id").group(:id).select("posts.*")

      relation = relation.select("COUNT(pools.id) AS pool_count")
      relation = relation.select("COUNT(pools.id) FILTER (WHERE pools.is_deleted = TRUE) AS deleted_pool_count")
      relation = relation.select("COUNT(pools.id) FILTER (WHERE pools.is_deleted = FALSE) AS active_pool_count")
      relation = relation.select("COUNT(pools.id) FILTER (WHERE pools.category = 'series') AS series_pool_count")
      relation = relation.select("COUNT(pools.id) FILTER (WHERE pools.category = 'collection') AS collection_pool_count")
      relation
    end

    def with_queued_at
      relation = group(:id)
      relation = relation.left_outer_joins(:flags, :appeals)
      relation = relation.select("posts.*")
      relation = relation.select(Arel.sql("MAX(GREATEST(posts.created_at, post_flags.created_at, post_appeals.created_at)) AS queued_at"))
      relation
    end

    def with_stats(tables)
      return all if tables.empty?

      relation = all
      tables.each do |table|
        relation = relation.send("with_#{table}_stats")
      end

      from(relation.arel.as("posts"))
    end

    def available_for_moderation(user, hidden: false)
      return none if user.is_anonymous?

      approved_posts = user.post_approvals.select(:post_id)
      disapproved_posts = user.post_disapprovals.select(:post_id)

      if hidden.present?
        where("posts.uploader_id = ? OR posts.id IN (#{approved_posts.to_sql}) OR posts.id IN (#{disapproved_posts.to_sql})", user.id)
      else
        where.not(uploader: user).where.not(id: approved_posts).where.not(id: disapproved_posts)
      end
    end

    def raw_tag_match(tag)
      Post.where_array_includes_all("string_to_array(posts.tag_string, ' ')", [tag])
    end

    # Perform a tag search as an anonymous user. No tag limit is enforced.
    def anon_tag_match(query)
      user_tag_match(query, User.anonymous, tag_limit: nil, safe_mode: false, hide_deleted_posts: false)
    end

    # Perform a tag search as the system user, DanbooruBot. The search will
    # have moderator-level permissions. No tag limit is enforced.
    def system_tag_match(query)
      user_tag_match(query, User.system, tag_limit: nil, safe_mode: false, hide_deleted_posts: false)
    end

    # Perform a tag search as the current user, or as another user.
    #
    # @param query [String] the tag search to perform
    # @param user [User] the user to perform the search as
    # @param tag_limit [Integer] the maximum number of tags allowed per search.
    #   An exception will be raised if the search has too many tags.
    # @param safe_mode [Boolean] if true, automatically add rating:s to the search
    # @param hide_deleted_posts [Boolean] if true, automatically add -status:deleted to the search
    # @return [ActiveRecord::Relation<Post>] the set of resulting posts
    def user_tag_match(query, user = CurrentUser.user, tag_limit: user.tag_query_limit, safe_mode: CurrentUser.safe_mode?, hide_deleted_posts: user.hide_deleted_posts?)
      post_query = PostQueryBuilder.new(query, user, tag_limit: tag_limit, safe_mode: safe_mode, hide_deleted_posts: hide_deleted_posts)
      post_query.normalized_query.build
    end

    def search(params)
      q = search_attributes(
        params,
        :id, :created_at, :updated_at, :rating, :source, :pixiv_id, :fav_count,
        :score, :up_score, :down_score, :md5, :file_ext, :file_size, :image_width,
        :image_height, :tag_count, :has_children, :has_active_children,
        :is_pending, :is_flagged, :is_deleted, :is_banned,
        :last_comment_bumped_at, :last_commented_at, :last_noted_at,
        :uploader_ip_addr, :uploader, :approver, :parent,
        :artist_commentary, :flags, :appeals, :notes, :comments, :children,
        :approvals, :replacements, :pixiv_ugoira_frame_data
      )

      if params[:tags].present?
        q = q.user_tag_match(params[:tags])
      end

      if params[:order].present?
        q = PostQueryBuilder.new(nil).search_order(q, params[:order])
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  module PixivMethods
    def parse_pixiv_id
      self.pixiv_id = nil

      site = Sources::Strategies::Pixiv.new(source)
      if site.match?
        self.pixiv_id = site.illust_id
      end
    end
  end

  concerning :RegenerationMethods do
    def regenerate_later!(category, user)
      RegeneratePostJob.perform_later(post: self, category: category, user: user)
    end

    def regenerate!(category, user)
      if category == "iqdb"
        update_iqdb

        ModAction.log("<@#{user.name}> regenerated IQDB for post ##{id}", :post_regenerate_iqdb, user)
      else
        media_file = media_asset.variant(:original).open_file
        media_asset.distribute_files!(media_file)

        update!(
          image_width: media_file.width,
          image_height: media_file.height,
          file_size: media_file.file_size,
          file_ext: media_file.file_ext
        )

        media_asset.update!(
          image_width: media_file.width,
          image_height: media_file.height,
          file_size: media_file.file_size,
          file_ext: media_file.file_ext
        )

        purge_cached_urls!
        update_iqdb

        ModAction.log("<@#{user.name}> regenerated image samples for post ##{id}", :post_regenerate, user)
      end
    end

    def purge_cached_urls!
      urls = [
        preview_file_url, large_file_url, file_url,
        tagged_file_url(tagged_filenames: true), tagged_large_file_url(tagged_filenames: true),
      ]

      CloudflareService.new.purge_cache(urls)
    end
  end

  concerning :IqdbMethods do
    def update_iqdb
      # performs IqdbClient.new.add_post(post)
      IqdbAddPostJob.perform_later(self)
    end

    def remove_iqdb
      # performs IqdbClient.new.remove(id)
      IqdbRemovePostJob.perform_later(id)
    end
  end

  module ValidationMethods
    def post_is_not_its_own_parent
      if !new_record? && id == parent_id
        errors.add(:base, "Post cannot have itself as a parent")
      end
    end

    def uploader_is_not_limited
      errors.add(:uploader, "have reached your upload limit") if uploader.upload_limit.limited?
    end

    def added_tags_are_valid
      new_tags = added_tags.select(&:empty?)
      new_artist_tags, new_general_tags = new_tags.partition(&:artist?)

      if new_general_tags.present?
        n = new_general_tags.size
        tag_wiki_links = new_general_tags.map { |tag| "[[#{tag.name}]]" }
        warnings.add(:base, "Created #{n} new #{(n == 1) ? "tag" : "tags"}: #{tag_wiki_links.join(", ")}")
      end

      new_artist_tags.each do |tag|
        if tag.artist.blank?
          new_artist_path = Routes.new_artist_path(artist: { name: tag.name })
          warnings.add(:base, "Artist [[#{tag.name}]] requires an artist entry. \"Create new artist entry\":[#{new_artist_path}]")
        end
      end
    end

    def removed_tags_are_valid
      attempted_removed_tags = @removed_tags + @negated_tags
      unremoved_tags = tag_array & attempted_removed_tags

      if unremoved_tags.present?
        unremoved_tags_list = unremoved_tags.map { |t| "[[#{t}]]" }.to_sentence
        warnings.add(:base, "#{unremoved_tags_list} could not be removed. Check for implications and try again")
      end
    end

    def has_artist_tag
      return if !new_record?
      return if source !~ %r{\Ahttps?://}
      return if has_tag?("artist_request") || has_tag?("official_art")
      return if tags.any?(&:artist?)
      return if Sources::Strategies.find(source).is_a?(Sources::Strategies::Null)

      new_artist_path = Routes.new_artist_path(artist: { source: source })
      warnings.add(:base, "Artist tag is required. \"Create new artist tag\":[#{new_artist_path}]. Ask on the forum if you need naming help")
    end

    def has_copyright_tag
      return if !new_record?
      return if has_tag?("copyright_request") || tags.any?(&:copyright?)

      warnings.add(:base, "Copyright tag is required. Consider adding [[copyright request]] or [[original]]")
    end

    def has_enough_tags
      return if !new_record?

      if tags.count(&:general?) < 10
        warnings.add(:base, "Uploads must have at least 10 general tags. Read [[howto:tag]] for guidelines on tagging your uploads")
      end
    end
  end

  include FileMethods
  include ImageMethods
  include ApprovalMethods
  include PresenterMethods
  include TagMethods
  include FavoriteMethods
  include PoolMethods
  include VoteMethods
  include ParentMethods
  include DeletionMethods
  include VersionMethods
  include NoteMethods
  include ApiMethods
  extend SearchMethods
  include PixivMethods
  include ValidationMethods

  has_bit_flags ["has_embedded_notes"]

  def safeblocked?
    CurrentUser.safe_mode? && (rating != "s" || Danbooru.config.safe_mode_restricted_tags.any? { |tag| tag.in?(tag_array) })
  end

  def levelblocked?(user = CurrentUser.user)
    #!user.is_gold? && RESTRICTED_TAGS.any? { |tag| has_tag?(tag) }
    !user.is_gold? && tag_string.match?(RESTRICTED_TAGS_REGEX)
  end

  def banblocked?(user = CurrentUser.user)
    return false unless is_banned?
    (has_tag?("paid_reward") && !user.is_approver?) || !user.is_gold?
  end

  def visible?(user = CurrentUser.user)
    !safeblocked? && !levelblocked?(user) && !banblocked?(user)
  end

  def reload(options = nil)
    super
    @pools = nil
    @tag_categories = nil
    @typed_tags = nil
    self
  end

  def self.normalize_source(source)
    source.to_s.strip.unicode_normalize(:nfc)
  end

  def mark_as_translated(params)
    add_tag("check_translation") if params["check_translation"].to_s.truthy?
    remove_tag("check_translation") if params["check_translation"].to_s.falsy?

    add_tag("partially_translated") if params["partially_translated"].to_s.truthy?
    remove_tag("partially_translated") if params["partially_translated"].to_s.falsy?

    if has_tag?("check_translation") || has_tag?("partially_translated")
      add_tag("translation_request")
      remove_tag("translated")
    else
      add_tag("translated")
      remove_tag("translation_request")
    end

    save
  end

  def self.model_restriction(table)
    super.where(table[:is_pending].eq(false)).where(table[:is_flagged].eq(false)).where(table[:is_deleted].eq(false))
  end

  def self.available_includes
    # attributes accessible through the ?only= parameter
    %i[
      uploader approver flags appeals parent children notes
      comments approvals disapprovals replacements pixiv_ugoira_frame_data
      artist_commentary
    ]
  end
end
