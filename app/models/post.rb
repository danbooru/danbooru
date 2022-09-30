# frozen_string_literal: true

class Post < ApplicationRecord
  class RevertError < StandardError; end
  class DeletionError < StandardError; end

  # Tags to copy when copying notes.
  NOTE_COPY_TAGS = %w[translated partially_translated check_translation translation_request reverse_translation
                      annotated partially_annotated check_annotation annotation_request]

  RESTRICTED_TAGS_REGEX = /(?:^| )(?:#{Danbooru.config.restricted_tags.join("|")})(?:$| )/o

  RATINGS = {
    g: "General",
    s: "Sensitive",
    q: "Questionable",
    e: "Explicit",
  }.with_indifferent_access

  RATING_ALIASES = {
    safe: ["s"],
    nsfw: ["q", "e"],
    sfw: ["g", "s"],
  }.with_indifferent_access

  deletable
  has_bit_flags %w[has_embedded_notes _unused_has_cropped is_taken_down]

  normalize :source, :normalize_source
  before_validation :merge_old_changes
  before_validation :apply_pre_metatags
  before_validation :normalize_tags
  before_validation :blank_out_nonexistent_parents
  before_validation :remove_parent_loops
  validates :md5, uniqueness: { message: ->(post, _data) { "Duplicate of post ##{Post.find_by_md5(post.md5).id}" }}, on: :create
  validates :rating, presence: { message: "not selected" }
  validates :rating, inclusion: { in: RATINGS.keys, message: "must be #{RATINGS.keys.map(&:upcase).to_sentence(last_word_connector: ", or ")}" }, if: -> { rating.present? }
  validates :source, length: { maximum: 1200 }
  validate :post_is_not_its_own_parent
  validate :uploader_is_not_limited, on: :create
  before_save :parse_pixiv_id
  before_save :added_tags_are_valid
  before_save :removed_tags_are_valid
  before_save :has_artist_tag
  before_save :has_copyright_tag
  before_save :has_enough_tags
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
  has_many :ai_tags, through: :media_asset
  has_many :events, class_name: "PostEvent"
  has_many :mod_actions, as: :subject, dependent: :destroy

  attr_accessor :old_tag_string, :old_parent_id, :old_source, :old_rating, :has_constraints, :disable_versioning, :post_edit

  scope :pending, -> { where(is_pending: true) }
  scope :flagged, -> { where(is_flagged: true) }
  scope :banned, -> { where(is_banned: true) }
  # XXX conflict with deletable
  scope :active, -> { where(is_pending: false, is_deleted: false, is_flagged: false).where.not(id: PostAppeal.pending) }
  scope :appealed, -> { where(id: PostAppeal.pending.select(:post_id)) }
  scope :in_modqueue, -> { where_union(pending, flagged, appealed) }
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
      tag_string = "#{tag_string} #{upload_media_asset.source_extractor&.artists.to_a.map(&:tag).map(&:name).join(" ")}".strip
      tag_string += " " if tag_string.present?
    end

    post = Post.new(
      uploader: upload.uploader,
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

  concerning :FileMethods do
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

  concerning :ImageMethods do
    def twitter_card_supported?
      image_width.to_i >= 280 && image_height.to_i >= 150
    end

    def has_large?
      return false if has_tag?("animated_gif") || has_tag?("animated_png")
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

  concerning :ApprovalMethods do
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

    def autoban
      if has_tag?("banned_artist") || has_tag?("paid_reward")
        self.is_banned = true
      end
    end
  end

  concerning :PresenterMethods do
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
      RATINGS.fetch(rating)
    end

    def parsed_source
      Source::URL.parse(source) if web_source?
    end

    def normalized_source
      parsed_source&.page_url || source
    end

    def source_domain
      parsed_source&.domain.to_s
    end
  end

  concerning :TagMethods do
    def tag_array
      tag_string.split
    end

    def tag_array_was
      tag_string_was.split
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

      @post_edit = PostEdit.new(self, tag_string_was, old_tag_string || tag_string_was, tag_string)
    end

    def normalize_tags
      self.tag_string = Tag.create_for_list(post_edit.tag_names).uniq.sort.join(" ")
    end

    def add_automatic_tags(tags)
      tags -= %w[incredibly_absurdres absurdres highres lowres flash video ugoira animated_gif animated_png exif_rotation non-repeating_animation non-web_source wide_image tall_image]

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

      if source.present? && !web_source?
        tags << "non-web_source"
      end

      source_url = parsed_source
      if source_url.present? && source_url.recognized?
        # A bad_link is an image URL from a recognized site that can't be converted to a page URL.
        if source_url.image_url? && source_url.page_url.nil?
          tags << "bad_link"
        else
          tags -= ["bad_link"]
        end

        # A bad_source is a source from a recognized site that isn't an image url or a page url.
        if !source_url.image_url? && !source_url.page_url?
          tags << "bad_source"
        else
          tags -= ["bad_source"]
        end
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

    def apply_post_metatags
      post_edit.post_metatag_terms.each do |metatag|
        case [metatag.name, metatag.value]
        in "-pool", /^\d+$/ => pool_id
          pool = Pool.find_by_id(pool_id)
          pool&.remove!(self)

        in "-pool", name
          pool = Pool.find_by_name(name)
          pool&.remove!(self)

        in "pool", /^\d+$/ => pool_id
          pool = Pool.find_by_id(pool_id)
          pool&.add!(self)

        in "pool", name
          pool = Pool.find_by_name(name)
          pool&.add!(self)

        in "newpool", name
          pool = Pool.find_by_name(name)

          # XXX race condition
          if pool.nil?
            Pool.create!(name: name, description: "This pool was automatically generated", post_ids: [id])
          else
            pool.add!(self)
          end

        in "fav", name
          raise User::PrivilegeError unless Pundit.policy!(CurrentUser.user, Favorite).create?
          Favorite.create(post: self, user: CurrentUser.user)

        in "-fav", name
          raise User::PrivilegeError unless Pundit.policy!(CurrentUser.user, Favorite).create?
          Favorite.destroy_by(post: self, user: CurrentUser.user)

        in "upvote", name
          vote!(1, CurrentUser.user)

        in "downvote", name
          vote!(-1, CurrentUser.user)

        in "status", "active"
          raise User::PrivilegeError unless CurrentUser.is_approver?
          approvals.create!(user: CurrentUser.user)

        in "status", "banned"
          raise User::PrivilegeError unless CurrentUser.is_approver?
          ban!(CurrentUser.user)

        in "-status", "banned"
          raise User::PrivilegeError unless CurrentUser.is_approver?
          unban!(CurrentUser.user)

        in "disapproved", reason
          raise User::PrivilegeError unless CurrentUser.is_approver?
          disapprovals.create!(user: CurrentUser.user, reason: reason.downcase)

        in "child", "none"
          children.each do |post|
            post.update!(parent_id: nil)
          end

        in "-child", ids
          next if ids.blank?

          children.where_numeric_matches(:id, ids).each do |post|
            post.update!(parent_id: nil)
          end

        in "child", ids
          next if ids.blank?

          Post.where_numeric_matches(:id, ids).where.not(id: id).limit(10).each do |post|
            post.update!(parent_id: id)
          end

        in "-favgroup", name
          favgroup = FavoriteGroup.find_by_name_or_id!(name, CurrentUser.user)
          raise User::PrivilegeError unless Pundit.policy!(CurrentUser.user, favgroup).update?
          favgroup&.remove(self)

        in "favgroup", name
          favgroup = FavoriteGroup.find_by_name_or_id!(name, CurrentUser.user)
          raise User::PrivilegeError unless Pundit.policy!(CurrentUser.user, favgroup).update?
          favgroup&.add(self)

        end
      end
    rescue
      # XXX Silently ignore errors so that the edit doesn't fail. We can't let
      # the edit fail because then it will create a new post version even if
      # the edit didn't go through.
      nil
    end

    def apply_pre_metatags
      post_edit.pre_metatag_terms.each do |metatag|
        case [metatag.name, metatag.value]
        in "parent", ("none" | "0")
          self.parent_id = nil

        in "-parent", /^\d+$/ => new_parent_id
          if parent_id == new_parent_id.to_i
            self.parent_id = nil
          end

        in "parent", /^\d+$/ => new_parent_id
          if new_parent_id.to_i != id && Post.exists?(new_parent_id)
            self.parent_id = new_parent_id.to_i
            remove_parent_loops
          end

        in "rating", /\A([#{RATINGS.keys.join}])/i
          self.rating = $1.downcase

        in "source", "none"
          self.source = ""

        in "source", value
          self.source = value

        in category, name if category.in?(PostEdit::CATEGORIZATION_METATAGS)
          Tag.find_or_create_by_name(name, category: category, current_user: CurrentUser.user)

        else
          nil

        end
      end
    end

    def web_source?
      source.match?(%r{\Ahttps?://}i)
    end

    def has_tag?(tag)
      tag_array.include?(tag)
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

  concerning :FavoriteMethods do
    def favorited_by?(user)
      return false if user.is_anonymous?
      Favorite.exists?(post: self, user: user)
    end

    def favorite_groups
      FavoriteGroup.for_post(id)
    end

    def remove_from_fav_groups
      FavoriteGroup.for_post(id).find_each do |favgroup|
        favgroup.remove(self)
      end
    end
  end

  concerning :PoolMethods do
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

  concerning :VoteMethods do
    def vote!(score, voter)
      # Ignore vote if user doesn't have permission to vote.
      return unless Pundit.policy!(voter, PostVote).create?

      with_lock do
        votes.create!(user: voter, score: score) unless votes.active.exists?(user: voter, score: score)
        reload # PostVote.create modifies our score. Reload to get the new score.
      end
    end
  end

  concerning :ParentMethods do
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
    rescue
      # XXX Silently ignore errors so that the edit doesn't fail. We can't let
      # the edit fail because then it will create a new post version even if
      # the edit didn't go through.
      nil
    end

    def give_favorites_to_parent(current_user = CurrentUser.user)
      return if parent.nil?

      transaction do
        favorites.each do |fav|
          fav.destroy!
          Favorite.create(post: parent, user: fav.user)
        end
      end

      ModAction.log("moved favorites from post ##{id} to post ##{parent.id}", :post_move_favorites, subject: self, user: current_user)
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

  concerning :DeletionMethods do
    def expunge!(current_user = CurrentUser.user)
      transaction do
        Post.without_timeout do
          ModAction.log("permanently deleted post ##{id} (md5=#{md5})", :post_permanent_delete, subject: nil, user: current_user)

          update_children_on_destroy
          decrement_tag_post_counts
          remove_from_all_pools
          remove_from_fav_groups
          media_asset.trash!
          destroy
          update_parent_on_destroy
        end
      end

      remove_iqdb # this is non-transactional
    end

    def ban!(current_user)
      return if is_banned?
      update_column(:is_banned, true)
      ModAction.log("banned post ##{id}", :post_ban, subject: self, user: current_user)
    end

    def unban!(current_user)
      return unless is_banned?
      update_column(:is_banned, false)
      ModAction.log("unbanned post ##{id}", :post_unban, subject: self, user: current_user)
    end

    def delete!(reason, move_favorites: false, user: CurrentUser.user)
      with_lock do
        automated = (user == User.system)

        flags.pending.update!(status: :succeeded)
        appeals.pending.update!(status: :rejected)

        flags.create!(reason: reason, is_deletion: true, creator: user, status: :succeeded)
        update!(is_deleted: true, is_pending: false, is_flagged: false)

        # XXX This must happen *after* the `is_deleted` flag is set to true (issue #3419).
        give_favorites_to_parent if move_favorites

        uploader.upload_limit.update_limit!(is_pending?, false)

        unless automated
          ModAction.log("deleted post ##{id}, reason: #{reason}", :post_delete, subject: self, user: user)
        end
      end
    end
  end

  concerning :VersionMethods do
    # XXX `create_version` must be called before `apply_post_metatags` because
    # `apply_post_metatags` may update the post itself, which will clear all
    # changes to the post and make saved_change_to_*? return false.
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

  concerning :NoteMethods do
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

  concerning :ApiMethods do
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

  concerning :SearchMethods do
    class_methods do
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
        where("md5 < ?", key).reorder(md5: :desc).first
      end

      def random_down(key)
        where("md5 >= ?", key).reorder(md5: :asc).first
      end

      def sample(query, sample_size)
        user_tag_match(query, safe_mode: false).reorder(:md5).limit(sample_size)
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
        disapproved_posts = user.post_disapprovals.select(:post_id)

        if hidden.present?
          in_modqueue.where(id: disapproved_posts)
        else
          in_modqueue.where.not(id: disapproved_posts)
        end
      end

      def is_matches(value, current_user = User.anonymous)
        case value.downcase
        when "parent"
          where(has_children: true)
        when "child"
          where.not(parent: nil)
        when *AutocompleteService::POST_STATUSES
          status_matches(value, current_user)
        when *MediaAsset::FILE_TYPES
          attribute_matches(value, :file_ext, :enum)
        when *Post::RATINGS.values.map(&:downcase)
          rating_matches(value)
        when *Post::RATING_ALIASES.keys
          where(rating: Post::RATING_ALIASES.fetch(value.downcase))
        else
          none
        end
      end

      def has_matches(value)
        case value.downcase
        when "parent"
          where.not(parent: nil)
        when "child", "children"
          where(has_children: true)
        when "source"
          where.not(source: "")
        when "appeals"
          where(PostAppeal.where("post_appeals.post_id = posts.id").arel.exists)
        when "flags"
          where(PostFlag.by_users.where("post_flags.post_id = posts.id").arel.exists)
        when "replacements"
          where(PostReplacement.where("post_replacements.post_id = posts.id").arel.exists)
        when "comments"
          where(Comment.undeleted.where("comments.post_id = posts.id").arel.exists)
        when "commentary"
          where(ArtistCommentary.undeleted.where("artist_commentaries.post_id = posts.id").arel.exists)
        when "notes"
          where(Note.active.where("notes.post_id = posts.id").arel.exists)
        when "pools"
          where(id: Pool.undeleted.select("unnest(post_ids)"))
        else
          none
        end
      end

      def status_matches(status, current_user = User.anonymous)
        case status.downcase
        when "pending"
          pending
        when "flagged"
          flagged
        when "appealed"
          appealed
        when "modqueue"
          in_modqueue
        when "deleted"
          deleted
        when "banned"
          banned
        when "active"
          active
        when "unmoderated"
          available_for_moderation(current_user, hidden: false)
        when "all", "any"
          where("TRUE")
        else
          none
        end
      end

      def parent_matches(parent)
        case parent.downcase
        when "none"
          where(parent: nil)
        when "any"
          where.not(parent: nil)
        when "pending", "flagged", "appealed", "modqueue", "deleted", "banned", "active", "unmoderated"
          where.not(parent: nil).where(parent: status_matches(parent))
        when /\A\d+\z/
          # XXX must use `attribute_matches(parent, :parent_id)` instead of `where(parent_id: parent)` so that `-parent:1` works
          where(id: parent).or(attribute_matches(parent, :parent_id))
        else
          none
        end
      end

      def child_matches(child)
        case child.downcase
        when "none"
          where(has_children: false)
        when "any"
          where(has_children: true)
        when "pending", "flagged", "appealed", "modqueue", "deleted", "banned", "active", "unmoderated"
          where(has_children: true).where(children: status_matches(child))
        else
          none
        end
      end

      def rating_matches(rating)
        where(rating: rating.downcase.split(/,/).map(&:first))
      end

      def source_matches(source, quoted = false)
        if source.empty?
          where(source: "")
        elsif source.downcase == "none" && !quoted
          where(source: "")
        else
          where_ilike(:source, source + "*")
        end
      end

      def embedded_matches(embedded)
        if embedded.truthy?
          bit_flags_match(:has_embedded_notes, true)
        elsif embedded.falsy?
          bit_flags_match(:has_embedded_notes, false)
        else
          none
        end
      end

      def commentary_matches(query, quoted = false)
        case query.downcase
        in "none" | "false" unless quoted
          where.not(artist_commentary: ArtistCommentary.all).or(where(artist_commentary: ArtistCommentary.deleted))
        in "any" | "true" unless quoted
          where(artist_commentary: ArtistCommentary.undeleted)
        in "translated" unless quoted
          where(artist_commentary: ArtistCommentary.translated)
        in "untranslated" unless quoted
          where(artist_commentary: ArtistCommentary.untranslated)
        else
          where(artist_commentary: ArtistCommentary.text_matches(query))
        end
      end

      def disapproved_matches(query, current_user = User.anonymous)
        if query.downcase.in?(PostDisapproval::REASONS)
          where(disapprovals: PostDisapproval.where(reason: query.downcase))
        else
          user = User.find_by_name(query)
          where(disapprovals: PostDisapproval.visible_for_search(:user, current_user).where(user: user))
        end
      end

      def note_matches(query)
        where(notes: Note.where_text_matches(:body, query))
      end

      def comment_matches(query)
        where(comments: Comment.where_text_matches(:body, query))
      end

      def saved_search_matches(label, current_user = User.anonymous)
        case label.downcase
        when "all"
          where(id: SavedSearch.post_ids_for(current_user.id))
        else
          where(id: SavedSearch.post_ids_for(current_user.id, label: label))
        end
      end

      def pool_matches(pool_name)
        case pool_name.downcase
        when "none"
          where.not(id: Pool.select("unnest(post_ids)"))
        when "any"
          where(id: Pool.select("unnest(post_ids)"))
        when "series"
          where(id: Pool.series.select("unnest(post_ids)"))
        when "collection"
          where(id: Pool.collection.select("unnest(post_ids)"))
        when /\*/
          where(id: Pool.name_contains(pool_name).select("unnest(post_ids)"))
        else
          where(id: Pool.named(pool_name).select("unnest(post_ids)"))
        end
      end

      def ordpool_matches(pool_name)
        # XXX unify with Pool#posts
        pool_posts = Pool.named(pool_name).joins("CROSS JOIN unnest(pools.post_ids) WITH ORDINALITY AS row(post_id, pool_index)").select(:post_id, :pool_index)
        joins("JOIN (#{pool_posts.to_sql}) pool_posts ON pool_posts.post_id = posts.id").order("pool_posts.pool_index ASC")
      end

      def favgroup_matches(query, current_user)
        case query.downcase
        when "none"
          favgroups = FavoriteGroup.where(creator: current_user)
          where.not(id: favgroups.select("unnest(post_ids)"))
        when "any"
          favgroups = FavoriteGroup.where(creator: current_user)
          where(id: favgroups.select("unnest(post_ids)"))
        else
          favgroup = FavoriteGroup.visible(current_user).name_or_id_matches(query, current_user)
          where(id: favgroup.select("unnest(post_ids)"))
        end
      end

      def ordfavgroup_matches(query, current_user)
        # XXX unify with FavoriteGroup#posts
        favgroup = FavoriteGroup.visible(current_user).name_or_id_matches(query, current_user)
        favgroup_posts = favgroup.joins("CROSS JOIN unnest(favorite_groups.post_ids) WITH ORDINALITY AS row(post_id, favgroup_index)").select(:post_id, :favgroup_index)
        joins("JOIN (#{favgroup_posts.to_sql}) favgroup_posts ON favgroup_posts.post_id = posts.id").order("favgroup_posts.favgroup_index ASC")
      end

      def favorites_include(username, current_user = User.anonymous)
        favuser = User.find_by_name(username)

        if favuser.present? && Pundit.policy!(current_user, favuser).can_see_favorites?
          where(id: favuser.favorites.select(:post_id))
        else
          none
        end
      end

      def ordfav_matches(username, current_user = User.anonymous)
        user = User.find_by_name(username)

        if user.present? && Pundit.policy!(current_user, user).can_see_favorites?
          joins(:favorites).merge(Favorite.where(user: user)).order("favorites.id DESC")
        else
          none
        end
      end

      def exif_matches(string)
        # string = exif:File:ColorComponents=3
        if string.include?("=")
          key, value = string.split(/=/, 2)
          hash = { key => value }
          metadata = MediaMetadata.joins(:media_asset).where_json_contains(:metadata, hash)
        # string = exif:File:ColorComponents
        else
          metadata = MediaMetadata.joins(:media_asset).where_json_has_key(:metadata, string)
        end

        where(md5: metadata.select(:md5))
      end

      def ai_tags_include(value, default_confidence: ">=50")
        name, confidence = value.split(",")
        confidence = (confidence || default_confidence).to_s.delete("%")

        tag = Tag.find_by_name_or_alias(name)
        return none if tag.nil?

        if confidence == "0"
          ai_tags = AITag.joins(:media_asset).where(tag: tag)
          where.not(ai_tags.where("media_assets.md5 = posts.md5").arel.exists)
        else
          ai_tags = AITag.joins(:media_asset).where(tag: tag).where_numeric_matches(:score, confidence)
          where(ai_tags.where("media_assets.md5 = posts.md5").arel.exists)
        end
      end

      def uploader_matches(username)
        case username.downcase
        when "any"
          where.not(uploader: nil)
        when "none"
          where(uploader: nil)
        else
          user = User.find_by_name(username)
          return none if user.nil?
          where(uploader: user)
        end
      end

      def approver_matches(username)
        case username.downcase
        when "any"
          where.not(approver: nil)
        when "none"
          where(approver: nil)
        else
          user = User.find_by_name(username)
          return none if user.nil?

          # XXX must use `attribute_matches(user.id, :approver_id)` instead of `where(approver: user)` so that `-approver:evazion` works
          attribute_matches(user.id, :approver_id)
        end
      end

      def user_subquery_matches(subquery, username, current_user, field: :creator)
        subquery = subquery.where("post_id = posts.id").select(1)

        if username.downcase == "any"
          where("EXISTS (#{subquery.to_sql})")
        elsif username.downcase == "none"
          where("NOT EXISTS (#{subquery.to_sql})")
        else
          user = User.find_by_name(username)
          return none if user.nil?
          subquery = subquery.visible_for_search(field, current_user).where(field => user)
          where("EXISTS (#{subquery.to_sql})")
        end
      end

      def tags_include(*tags)
        where_array_includes_all("string_to_array(posts.tag_string, ' ')", tags)
      end

      def raw_tag_match(tag)
        Post.where_array_includes_all("string_to_array(posts.tag_string, ' ')", [tag])
      end

      # Perform a tag search as an anonymous user. No tag limit is enforced.
      def anon_tag_match(query)
        user_tag_match(query, User.anonymous, tag_limit: nil, safe_mode: false)
      end

      # Perform a tag search as the system user, DanbooruBot. The search will
      # have moderator-level permissions. No tag limit is enforced.
      def system_tag_match(query)
        user_tag_match(query, User.system, tag_limit: nil, safe_mode: false)
      end

      # Perform a tag search as the current user, or as another user.
      #
      # @param query [String] the tag search to perform
      # @param user [User] the user to perform the search as
      # @param tag_limit [Integer] the maximum number of tags allowed per search.
      #   An exception will be raised if the search has too many tags.
      # @param safe_mode [Boolean] if true, automatically add rating:s to the search
      # @return [ActiveRecord::Relation<Post>] the set of resulting posts
      def user_tag_match(query, user = CurrentUser.user, tag_limit: user.tag_query_limit, safe_mode: CurrentUser.safe_mode?)
        post_query = PostQuery.normalize(query, current_user: user, tag_limit: tag_limit, safe_mode: safe_mode)
        post_query.validate_tag_limit!
        posts = post_query.with_implicit_metatags.posts
        and_relation(posts)
      end

      def search(params, current_user)
        q = search_attributes(
          params,
          [:id, :created_at, :updated_at, :rating, :source, :pixiv_id, :fav_count,
          :score, :up_score, :down_score, :md5, :file_ext, :file_size, :image_width,
          :image_height, :tag_count, :has_children, :has_active_children,
          :is_pending, :is_flagged, :is_deleted, :is_banned,
          :last_comment_bumped_at, :last_commented_at, :last_noted_at,
          :uploader, :approver, :parent,
          :artist_commentary, :flags, :appeals, :notes, :comments, :children,
          :approvals, :replacements, :pixiv_ugoira_frame_data],
          current_user: current_user
        )

        if params[:tags].present?
          q = q.where(id: user_tag_match(params[:tags], current_user).select(:id))
        end

        if params[:order].present?
          q = PostQueryBuilder.new(nil).search_order(q, params[:order])
        else
          q = q.apply_default_order(params)
        end

        q
      end
    end
  end

  concerning :PixivMethods do
    def parse_pixiv_id
      self.pixiv_id = nil
      return unless web_source?

      site = Source::Extractor::Pixiv.new(source)
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

        ModAction.log("regenerated IQDB for post ##{id}", :post_regenerate_iqdb, subject: self, user: user)
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

        ModAction.log("regenerated image samples for post ##{id}", :post_regenerate, subject: self, user: user)
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

  concerning :ValidationMethods do
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

      post_edit.invalid_added_tags.each do |tag|
        tag.errors.messages.each do |_attribute, messages|
          warnings.add(:base, "Couldn't add tag: #{messages.join(';')}")
        end
      end

      deprecated_tags = post_edit.deprecated_added_tag_names
      if deprecated_tags.present?
        tag_list = deprecated_tags.map { |tag| "[[#{tag}]]" }.to_sentence
        warnings.add(:base, "The following tags are deprecated and could not be added: #{tag_list}")
      end
    end

    def removed_tags_are_valid
      attempted_removed_tags = post_edit.user_removed_tag_names
      unremoved_tags = tag_array & attempted_removed_tags

      if unremoved_tags.present?
        unremoved_tags_list = unremoved_tags.map { |t| "[[#{t}]]" }.to_sentence
        warnings.add(:base, "#{unremoved_tags_list} could not be removed. Check for implications and try again")
      end
    end

    def has_artist_tag
      return if !new_record?
      return if !web_source?
      return if has_tag?("artist_request") || has_tag?("official_art")
      return if tags.any?(&:artist?)
      return if Source::Extractor.find(source).is_a?(Source::Extractor::Null)

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

  def safeblocked?
    CurrentUser.safe_mode? && (rating != "g" || Danbooru.config.safe_mode_restricted_tags.any? { |tag| tag.in?(tag_array) })
  end

  def levelblocked?(user = CurrentUser.user)
    #!user.is_gold? && RESTRICTED_TAGS.any? { |tag| has_tag?(tag) }
    !user.is_gold? && tag_string.match?(RESTRICTED_TAGS_REGEX)
  end

  def banblocked?(user = CurrentUser.user)
    return true if is_taken_down? && !user.is_moderator?
    return true if is_banned? && has_tag?("paid_reward") && !user.is_approver?
    return true if is_banned? && !user.is_gold?
    false
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
      uploader approver flags appeals events parent children notes
      comments approvals disapprovals replacements pixiv_ugoira_frame_data
      artist_commentary media_asset ai_tags
    ]
  end
end
