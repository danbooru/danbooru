# frozen_string_literal: true

class Comment < ApplicationRecord
  MAX_IMAGES = 1
  MAX_VIDEO_SIZE = 1.megabyte
  MAX_LARGE_EMOJI = 1
  MAX_SMALL_EMOJI = 100

  attr_accessor :creator_ip_addr

  belongs_to :post
  belongs_to :creator, class_name: "User"
  belongs_to_updater

  has_many :moderation_reports, as: :model, dependent: :destroy
  has_many :pending_moderation_reports, -> { pending }, as: :model, class_name: "ModerationReport"
  has_many :votes, class_name: "CommentVote", dependent: :destroy
  has_many :active_votes, -> { active }, class_name: "CommentVote"
  has_many :mod_actions, as: :subject, dependent: :destroy

  validates :body, visible_string: true, length: { maximum: 15_000 }, if: :body_changed?
  validate :validate_body, if: :body_changed?
  validate :validate_comment

  before_create :autoreport_spam
  before_save :handle_reports_on_deletion
  after_create :update_last_commented_at_on_create
  after_update(:if => ->(rec) {(!rec.is_deleted? || !rec.saved_change_to_is_deleted?) && CurrentUser.id != rec.creator_id}) do |comment|
    ModAction.log("updated #{comment.dtext_shortlink}", :comment_update, subject: self, user: comment.updater)
  end
  after_save :update_last_commented_at_on_destroy, :if => ->(rec) {rec.is_deleted? && rec.saved_change_to_is_deleted?}
  after_save(:if => ->(rec) {rec.is_deleted? && rec.saved_change_to_is_deleted? && CurrentUser.id != rec.creator_id}) do |comment|
    ModAction.log("deleted #{comment.dtext_shortlink}", :comment_delete, subject: self, user: comment.updater)
  end

  deletable
  dtext_attribute :body, media_embeds: true # defines :dtext_body

  mentionable(
    message_field: :body,
    title: ->(_user_name) {"#{creator.name} mentioned you in a comment on post ##{post_id}"},
    body: ->(user_name) {"@#{creator.name} mentioned you in comment ##{id} on post ##{post_id}:\n\n[quote]\n#{DText.new(body).extract_mention("@#{user_name}")}\n[/quote]\n"}
  )

  module SearchMethods
    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :is_deleted, :is_sticky, :do_not_bump_post, :body, :score, :post, :creator, :updater], current_user: current_user)

      if params[:is_edited].to_s.truthy?
        q = q.where("comments.updated_at - comments.created_at > ?", 5.minutes.iso8601)
      elsif params[:is_edited].to_s.falsy?
        q = q.where("comments.updated_at - comments.created_at <= ?", 5.minutes.iso8601)
      end

      case params[:order]
      when "id_asc"
        q = q.order("comments.id ASC")
      when "created_at", "created_at_desc"
        q = q.order("comments.created_at DESC, comments.id DESC")
      when "created_at_asc"
        q = q.order("comments.created_at ASC, comments.id ASC")
      when "post_id", "post_id_desc"
        q = q.order("comments.post_id DESC, comments.id DESC")
      when "score", "score_desc"
        q = q.order("comments.score DESC, comments.id DESC")
      when "score_asc"
        q = q.order("comments.score ASC, comments.id ASC")
      when "updated_at", "updated_at_desc"
        q = q.order("comments.updated_at DESC, comments.id DESC")
      when "updated_at_asc"
        q = q.order("comments.updated_at ASC, comments.id ASC")
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  extend SearchMethods

  def validate_body
    if dtext_body.block_emoji_names.count > MAX_LARGE_EMOJI
      errors.add(:base, "Can't include more than #{MAX_LARGE_EMOJI} #{"sticker".pluralize(MAX_LARGE_EMOJI)}")
    end

    if dtext_body.inline_emoji_names.count > MAX_SMALL_EMOJI
      errors.add(:base, "Can't include more than #{MAX_SMALL_EMOJI} #{"emoji".pluralize(MAX_SMALL_EMOJI)}")
    end

    if dtext_body.embedded_media.count > MAX_IMAGES
      errors.add(:base, "Can't include more than #{MAX_IMAGES} #{"image".pluralize(MAX_IMAGES)}")
      return # don't check the actual images if the user included too many images
    end

    if dtext_body.embedded_posts.any? { _1.is_video? && _1.file_size > MAX_VIDEO_SIZE } || dtext_body.embedded_media_assets.any? { _1.is_video? && _1.file_size > MAX_VIDEO_SIZE }
      errors.add(:base, "Can't include videos larger than #{MAX_VIDEO_SIZE.to_fs(:human_size)}")
    end

    if (embedded_post = dtext_body.embedded_posts.find { |embedded_post| embedded_post.rating_id > post.rating_id })
      errors.add(:base, "Can't post a #{embedded_post.pretty_rating.downcase} image on a #{post.pretty_rating.downcase} post")
    end

    if (embedded_asset = dtext_body.embedded_media_assets.find { |embedded_asset| embedded_asset.ai_rating_id > post.rating_id })
      errors.add(:base, "Can't post a #{embedded_asset.pretty_ai_rating.downcase} image on a #{post.pretty_rating.downcase} post")
    end
  end

  def validate_comment
    if CurrentUser.user.is_anonymous? && Danbooru::IpAddress.new(creator_ip_addr).is_proxy?
      errors.add(:base, "Your IP range is banned")
    end

    if CurrentUser.user.is_anonymous? && body.match?(Regexp.union(Danbooru.config.comment_blacklist))
      errors.add(:base, "Whoops, can't say that on a Christian imageboard!")
    end
  end

  def autoreport_spam
    if SpamDetector.new(self, user_ip: creator_ip_addr).spam?
      moderation_reports << ModerationReport.new(creator: User.system, reason: "Spam.")
    end
  end

  def update_last_commented_at_on_create
    Post.where(:id => post_id).update_all(:last_commented_at => created_at)
    if Comment.where(post_id: post_id).count <= Danbooru.config.comment_threshold && !do_not_bump_post?
      Post.where(:id => post_id).update_all(:last_comment_bumped_at => created_at)
    end
  end

  def update_last_commented_at_on_destroy
    other_comments = Comment.where("post_id = ? and id <> ?", post_id, id).order(id: :desc)
    if other_comments.count == 0
      Post.where(:id => post_id).update_all(:last_commented_at => nil)
    else
      Post.where(:id => post_id).update_all(:last_commented_at => other_comments.first.created_at)
    end

    other_comments = other_comments.where("do_not_bump_post = FALSE")
    if other_comments.count == 0
      Post.where(:id => post_id).update_all(:last_comment_bumped_at => nil)
    else
      Post.where(:id => post_id).update_all(:last_comment_bumped_at => other_comments.first.created_at)
    end
  end

  def handle_reports_on_deletion
    return unless Pundit.policy!(updater, ModerationReport).update?
    return unless moderation_reports.pending.present? && is_deleted_change == [false, true]

    moderation_reports.pending.update!(status: :handled, updater: updater)
  end

  def quoted_response
    DText.new(body).quote(creator.name)
  end

  concerning :DiscordMethods do
    def discord_author
      Discordrb::Webhooks::EmbedAuthor.new(name: "@#{creator.name}", url: creator.discord_url)
    end

    def discord_thumbnail(channel)
      return if (post.rating != 'g' && !channel.nsfw?) || !post.visible?(User.anonymous)
      Discordrb::Webhooks::EmbedThumbnail.new(url: post.media_asset.variant(:"360x360").file_url)
    end

    def discord_body
      DText.to_markdown(body).truncate(2000)
    end

    def discord_footer
      timestamp = "#{created_at.strftime("%F")}"

      Discordrb::Webhooks::EmbedFooter.new(
        text: "#{score}⇧ | #{timestamp}"
      )
    end
  end

  def self.available_includes
    [:post, :creator, :updater]
  end
end
