class ForumPost < ApplicationRecord
  attr_readonly :topic_id

  belongs_to :creator, class_name: "User"
  belongs_to_updater
  belongs_to :topic, class_name: "ForumTopic", inverse_of: :forum_posts

  has_many :dtext_links, as: :model, dependent: :destroy
  has_many :moderation_reports, as: :model
  has_many :votes, class_name: "ForumPostVote"
  has_one :tag_alias
  has_one :tag_implication
  has_one :bulk_update_request

  validates :body, presence: true, length: { maximum: 200_000 }, if: :body_changed?

  before_save :update_dtext_links, if: :dtext_links_changed?
  before_create :autoreport_spam
  after_create :update_topic_updated_at_on_create
  after_update :update_topic_updated_at_on_update_for_original_posts
  after_destroy :update_topic_updated_at_on_destroy
  after_save :delete_topic_if_original_post
  after_update(:if => ->(rec) {rec.updater_id != rec.creator_id}) do |rec|
    ModAction.log("#{CurrentUser.user.name} updated forum ##{rec.id}", :forum_post_update)
  end
  after_destroy(:if => ->(rec) {rec.updater_id != rec.creator_id}) do |rec|
    ModAction.log("#{CurrentUser.user.name} deleted forum ##{rec.id}", :forum_post_delete)
  end
  after_create_commit :async_send_discord_notification

  deletable
  mentionable(
    message_field: :body,
    title: ->(_user_name) {%{#{creator.name} mentioned you in topic ##{topic_id} (#{topic.title})}},
    body: ->(user_name) {%{@#{creator.name} mentioned you in topic ##{topic_id} ("#{topic.title}":[#{Routes.forum_topic_path(topic, page: forum_topic_page)}]):\n\n[quote]\n#{DText.extract_mention(body, "@#{user_name}")}\n[/quote]\n}}
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

    def search(params)
      q = search_attributes(params, :id, :created_at, :updated_at, :is_deleted, :body, :creator, :updater, :topic, :dtext_links, :votes, :tag_alias, :tag_implication, :bulk_update_request)
      q = q.text_attribute_matches(:body, params[:body_matches], index_column: :text_index)

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

  def autoreport_spam
    if SpamDetector.new(self, user_ip: CurrentUser.ip_addr).spam?
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

  def dtext_links_changed?
    body_changed? && DText.dtext_links_differ?(body, body_was)
  end

  def update_dtext_links
    self.dtext_links = DtextLink.new_from_dtext(body)
  end

  def update_topic_updated_at_on_delete
    max = ForumPost.where(:topic_id => topic.id, :is_deleted => false).order("updated_at desc").first
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
    max = ForumPost.where(:topic_id => topic.id, :is_deleted => false).order("updated_at desc").first
    if max
      ForumTopic.where(:id => topic.id).update_all(["response_count = response_count - 1, updated_at = ?, updater_id = ?", max.updated_at, max.updater_id])
    else
      ForumTopic.where(:id => topic.id).update_all("response_count = response_count - 1")
    end

    topic.response_count -= 1
  end

  def quoted_response
    DText.quote(body, creator.name)
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

  def delete_topic_if_original_post
    if is_deleted? && is_original_post?
      topic.update_attribute(:is_deleted, true)
    end
  end

  def async_send_discord_notification
    DiscordNotificationJob.perform_later(forum_post: self)
  end

  def send_discord_notification
    return unless policy(User.anonymous).show?
    DiscordWebhookService.new.post_message(self)
  end

  def build_response
    dup.tap do |x|
      x.body = x.quoted_response
    end
  end

  def dtext_shortlink(**options)
    "forum ##{id}"
  end

  def self.available_includes
    [:creator, :updater, :topic, :dtext_links, :votes, :tag_alias, :tag_implication, :bulk_update_request]
  end
end
