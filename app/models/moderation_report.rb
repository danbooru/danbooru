class ModerationReport < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :creator, class_name: "User"

  validates :reason, presence: true
  after_create :create_forum_post!

  scope :user, -> { where(model_type: "User") }
  scope :comment, -> { where(model_type: "Comment") }
  scope :forum_post, -> { where(model_type: "ForumPost") }
  scope :recent, -> { where("moderation_reports.created_at >= ?", 1.week.ago) }

  def self.enabled?
    !Rails.env.production?
  end

  def forum_topic_title
    "Reports requiring moderation"
  end

  def forum_topic_body
    "This topic deals with moderation events as reported by Builders. Reports can be filed against users, comments, or forum posts."
  end

  def forum_topic
    topic = ForumTopic.find_by_title(forum_topic_title)
    if topic.nil?
      CurrentUser.as_system do
        topic = ForumTopic.create!(creator: User.system, title: forum_topic_title, category_id: 0, min_level: User::Levels::MODERATOR)
        forum_post = ForumPost.create!(creator: User.system, body: forum_topic_body, topic: topic)
      end
    end
    topic
  end

  def forum_post_message
    messages = ["[b]Submitted by:[/b] @#{creator.name}"]
    case model_type
    when "User"
      messages << "[b]Submitted against:[/b] @#{model.name}"
    when "Comment"
      messages << "[b]Submitted against[/b]: comment ##{model_id}"
    when "ForumPost"
      messages << "[b]Submitted against[/b]: forum ##{model_id}"
    end
    messages << ""
    messages << "[quote]"
    messages << "[b]Reason:[/b]"
    messages << ""
    messages << reason
    messages << "[/quote]"
    messages.join("\n")
  end

  def create_forum_post!
    updater = ForumUpdater.new(forum_topic)
    updater.update(forum_post_message)
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :model_type, :model_id, :creator_id)

    q.apply_default_order(params)
  end
end
