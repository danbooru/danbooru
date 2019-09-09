class ForumPost < ApplicationRecord
  include Mentionable

  attr_readonly :topic_id
  belongs_to_creator
  belongs_to_updater
  belongs_to :topic, :class_name => "ForumTopic"
  has_many :votes, class_name: "ForumPostVote"
  has_one :tag_alias
  has_one :tag_implication
  has_one :bulk_update_request
  before_validation :initialize_is_deleted, :on => :create
  after_create :update_topic_updated_at_on_create
  after_update :update_topic_updated_at_on_update_for_original_posts
  after_destroy :update_topic_updated_at_on_destroy
  validates_presence_of :body
  validate :validate_topic_is_unlocked
  validate :validate_post_is_not_spam, on: :create
  validate :topic_is_not_restricted, :on => :create
  before_destroy :validate_topic_is_unlocked
  after_save :delete_topic_if_original_post
  after_update(:if => ->(rec) {rec.updater_id != rec.creator_id}) do |rec|
    ModAction.log("#{CurrentUser.name} updated forum ##{rec.id}",:forum_post_update)
  end
  after_destroy(:if => ->(rec) {rec.updater_id != rec.creator_id}) do |rec|
    ModAction.log("#{CurrentUser.name} deleted forum ##{rec.id}",:forum_post_delete)
  end
  mentionable(
    :message_field => :body, 
    :title => ->(user_name) {%{#{creator.name} mentioned you in topic ##{topic_id} (#{topic.title})}},
    :body => ->(user_name) {%{@#{creator.name} mentioned you in topic ##{topic_id} ("#{topic.title}":[/forum_topics/#{topic_id}?page=#{forum_topic_page}]):\n\n[quote]\n#{DText.excerpt(body, "@"+user_name)}\n[/quote]\n}},
  )

  module SearchMethods
    def topic_title_matches(title)
      joins(:topic).merge(ForumTopic.search(title_matches: title))
    end

    def active
      where("forum_posts.is_deleted = false")
    end

    def permitted
      joins(:topic).where("forum_topics.min_level <= ?", CurrentUser.level)
    end

    def search(params)
      q = super
      q = q.permitted
      q = q.search_attributes(params, :creator, :updater, :topic_id, :is_deleted, :body)
      q = q.text_attribute_matches(:body, params[:body_matches], index_column: :text_index)

      if params[:topic_title_matches].present?
        q = q.topic_title_matches(params[:topic_title_matches])
      end

      if params[:topic_category_id].present?
        q = q.joins(:topic).where("forum_topics.category_id = ?", params[:topic_category_id].to_i)
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

  def tag_change_request
    bulk_update_request || tag_alias || tag_implication
  end

  def votable?
    TagAlias.where(forum_post_id: id).exists? ||
      TagImplication.where(forum_post_id: id).exists? ||
      BulkUpdateRequest.where(forum_post_id: id).exists?
  end

  def voted?(user, score)
    votes.where(creator_id: user.id, score: score).exists?
  end

  def validate_post_is_not_spam
    errors[:base] << "Failed to create forum post" if SpamDetector.new(self, user_ip: CurrentUser.ip_addr).spam?
  end

  def validate_topic_is_unlocked
    return if CurrentUser.is_moderator?
    return if topic.nil?

    if topic.is_locked?
      errors[:topic] << "is locked"
      throw :abort
    end
  end

  def topic_is_not_restricted
    if topic && !topic.visible?(creator)
      errors[:topic] << "is restricted"
    end
  end

  def editable_by?(user)
    (creator_id == user.id || user.is_moderator?) && visible?(user)
  end

  def visible?(user, show_deleted_posts = false)
    user.is_moderator? || (topic.visible?(user) && (show_deleted_posts || !is_deleted?))
  end

  def update_topic_updated_at_on_create
    if topic
      # need to do this to bypass the topic's original post from getting touched
      ForumTopic.where(:id => topic.id).update_all(["updater_id = ?, response_count = response_count + 1, updated_at = ?", CurrentUser.id, Time.now])
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
      topic.response_count -= 1
    else
      ForumTopic.where(:id => topic.id).update_all("response_count = response_count - 1")
      topic.response_count -= 1
    end
  end

  def initialize_is_deleted
    self.is_deleted = false if is_deleted.nil?
  end

  def quoted_response
    DText.quote(body, creator.name)
  end

  def forum_topic_page
    ((ForumPost.where("topic_id = ? and created_at <= ?", topic_id, created_at).count) / Danbooru.config.posts_per_page.to_f).ceil
  end

  def is_original_post?(original_post_id = nil)
    if original_post_id
      return id == original_post_id
    else
      ForumPost.exists?(["id = ? and id = (select _.id from forum_posts _ where _.topic_id = ? order by _.id asc limit 1)", id, topic_id])
    end
  end

  def delete_topic_if_original_post
    if is_deleted? && is_original_post?
      topic.update_attribute(:is_deleted, true)
    end
  end

  def build_response
    dup.tap do |x|
      x.body = x.quoted_response
    end
  end
end
