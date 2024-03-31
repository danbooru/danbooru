# frozen_string_literal: true

class ForumPost < ApplicationRecord
  MAX_IMAGES = 1
  MAX_VIDEO_SIZE = 1.megabyte
  MAX_LARGE_EMOJI = 1
  MAX_SMALL_EMOJI = 100

  # attr_readonly :topic_id # XXX broken by accepts_nested_attributes_for in ForumTopic
  attr_accessor :creator_ip_addr

  dtext_attribute :body, media_embeds: true # defines :dtext_body

  belongs_to :creator, class_name: "User"
  belongs_to_updater
  belongs_to :topic, class_name: "ForumTopic", inverse_of: :forum_posts

  has_many :moderation_reports, as: :model
  has_many :pending_moderation_reports, -> { pending }, as: :model, class_name: "ModerationReport"
  has_many :votes, class_name: "ForumPostVote"
  has_many :mod_actions, as: :subject, dependent: :destroy
  has_one :tag_alias
  has_one :tag_implication
  has_one :bulk_update_request

  validates :body, visible_string: true, length: { maximum: 200_000 }, if: :body_changed?
  validate :validate_deletion_of_original_post
  validate :validate_undeletion_of_post
  validate :validate_body

  before_create :autoreport_spam
  before_save :handle_reports_on_deletion
  after_create :update_topic_updated_at_on_create
  after_update :update_topic_updated_at_on_update_for_original_posts
  after_destroy :update_topic_updated_at_on_destroy
  after_update :create_mod_action
  after_create_commit :async_send_discord_notification

  deletable
  has_dtext_links :body
  mentionable(
    message_field: :body,
    title: ->(_user_name) {%{#{creator.name} mentioned you in topic ##{topic_id} (#{topic.title})}},
    body: ->(user_name) {%{@#{creator.name} mentioned you in topic ##{topic_id} ("#{topic.title}":[#{Routes.forum_topic_path(topic, page: forum_topic_page)}]):\n\n[quote]\n#{DText.new(body).extract_mention("@#{user_name}")}\n[/quote]\n}}
  )

  module SearchMethods
    def visible(user)
      where(topic_id: ForumTopic.visible(user))
    end

    def not_visible(user)
      where.not(topic_id: ForumTopic.visible(user))
    end

    def wiki_link_matches(title)
      dtext_links = DtextLink.forum_post.wiki_link.where(link_target: WikiPage.normalize_title(title)).select(:model_id)
      bur_links = BulkUpdateRequest.where_array_includes_any(:tags, title).select(:forum_post_id)

      where(id: dtext_links).or(where(id: bur_links))
    end

    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :is_deleted, :body, :creator, :updater, :topic, :dtext_links, :votes, :tag_alias, :tag_implication, :bulk_update_request], current_user: current_user)

      if params[:linked_to].present?
        q = q.wiki_link_matches(params[:linked_to])
      end

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def self.new_reply(params)
    if params[:topic_id]
      new(:topic_id => params[:topic_id])
    elsif params[:post_id]
      forum_post = ForumPost.find(params[:post_id])
      forum_post.build_response
    else
      new
    end
  end

  def voted?(user, score)
    votes.exists?(creator_id: user.id, score: score)
  end

  def validate_deletion_of_original_post
    if is_original_post? && is_deleted? && !topic.is_deleted?
      errors.add(:base, "Can't delete original post without deleting the topic first")
    end
  end

  def validate_undeletion_of_post
    if topic.is_deleted? && !is_deleted?
      errors.add(:base, "Can't undelete post without undeleting the topic first")
    end
  end

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

    if dtext_body.embedded_posts.any? { |embedded_post| embedded_post.rating != "g" }
      errors.add(:base, "Can't post non-rating:G images")
    end

    if dtext_body.embedded_media_assets.any? { |embedded_asset| embedded_asset.ai_rating.first.in?(%w[q e]) }
      errors.add(:base, "Can't post non-rating:G images")
    end
  end

  def autoreport_spam
    if SpamDetector.new(self, user_ip: creator_ip_addr).spam?
      moderation_reports << ModerationReport.new(creator: User.system, reason: "Spam.")
    end
  end

  def update_topic_updated_at_on_create
    if topic
      # need to do this to bypass the topic's original post from getting touched
      ForumTopic.where(:id => topic.id).update_all(["updater_id = ?, response_count = response_count + 1, updated_at = ?", creator.id, Time.now])
      topic.response_count += 1
    end
  end

  def update_topic_updated_at_on_update_for_original_posts
    if is_original_post?
      topic.touch
    end
  end

  def delete!
    update(is_deleted: true)
    update_topic_updated_at_on_delete
  end

  def undelete!
    update(is_deleted: false)
    update_topic_updated_at_on_undelete
  end

  def update_topic_updated_at_on_delete
    max = ForumPost.where(topic_id: topic.id, is_deleted: false).order(updated_at: :desc).first
    if max
      ForumTopic.where(:id => topic.id).update_all(["updated_at = ?, updater_id = ?", max.updated_at, max.updater_id])
    end
  end

  def update_topic_updated_at_on_undelete
    if topic
      ForumTopic.where(:id => topic.id).update_all(["updater_id = ?, updated_at = ?", CurrentUser.id, Time.now])
    end
  end

  def update_topic_updated_at_on_destroy
    max = ForumPost.where(topic_id: topic.id, is_deleted: false).order(updated_at: :desc).first
    if max
      ForumTopic.where(:id => topic.id).update_all(["response_count = response_count - 1, updated_at = ?, updater_id = ?", max.updated_at, max.updater_id])
    else
      ForumTopic.where(:id => topic.id).update_all("response_count = response_count - 1")
    end

    topic.response_count -= 1
  end

  def create_mod_action
    if saved_change_to_is_deleted == [false, true] && creator != updater
      ModAction.log("deleted #{dtext_shortlink}", :forum_post_delete, subject: self, user: updater)
    elsif creator != updater
      ModAction.log("updated #{dtext_shortlink}", :forum_post_update, subject: self, user: updater)
    end
  end

  def quoted_response
    DText.new(body).quote(creator.name)
  end

  def forum_topic_page
    (ForumPost.where("topic_id = ? and created_at <= ?", topic_id, created_at).count / Danbooru.config.posts_per_page.to_f).ceil
  end

  def is_original_post?(original_post_id = nil)
    if original_post_id
      id == original_post_id
    else
      ForumPost.exists?(["id = ? and id = (select _.id from forum_posts _ where _.topic_id = ? order by _.id asc limit 1)", id, topic_id])
    end
  end

  def handle_reports_on_deletion
    return unless moderation_reports.pending.present? && is_deleted_change == [false, true]

    moderation_reports.pending.update!(status: :handled, updater: updater)
  end

  concerning :DiscordMethods do
    def async_send_discord_notification
      DiscordNotificationJob.perform_later(forum_post: self)
    end

    def send_discord_notification
      return unless policy(User.anonymous).show?
      DiscordWebhookService.new.post_message(self)
    end

    def discord_author
      Discordrb::Webhooks::EmbedAuthor.new(name: "@#{creator.name}", url: creator.discord_url)
    end

    def discord_title
      topic.title
    end

    def discord_body
      DText.to_markdown(body).truncate(2000)
    end
  end

  def build_response
    dup.tap do |x|
      x.body = x.quoted_response
    end
  end

  def dtext_shortlink(**_options)
    "forum ##{id}"
  end

  def self.available_includes
    [:creator, :updater, :topic, :dtext_links, :votes, :tag_alias, :tag_implication, :bulk_update_request]
  end
end
