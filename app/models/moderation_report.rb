class ModerationReport < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :creator, class_name: "User"

  validates :reason, presence: true
  validates :model_type, inclusion: { in: %w[Comment Dmail ForumPost User] }
  validates :creator, uniqueness: { scope: [:model_type, :model_id], message: "have already reported this message." }

  after_create :create_forum_post!
  after_create :autoban_reported_user

  scope :user, -> { where(model_type: "User") }
  scope :dmail, -> { where(model_type: "Dmail") }
  scope :comment, -> { where(model_type: "Comment") }
  scope :forum_post, -> { where(model_type: "ForumPost") }
  scope :recent, -> { where("moderation_reports.created_at >= ?", 1.week.ago) }

  def self.enabled?
    !Rails.env.production?
  end

  def self.model_types
    %w[User Dmail Comment ForumPost]
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
      CurrentUser.scoped(User.system) do
        topic = ForumTopic.create!(creator: User.system, title: forum_topic_title, category_id: 0, min_level: User::Levels::MODERATOR)
        forum_post = ForumPost.create!(creator: User.system, body: forum_topic_body, topic: topic)
      end
    end
    topic
  end

  def forum_post_message
    <<~EOS
      [b]Report[/b] modreport ##{id}
      [b]Submitted by[/b] <@#{creator.name}>
      [b]Submitted against[/b] #{model.dtext_shortlink(key: true)} by <@#{reported_user.name}>
      [b]Reason[/b] #{reason}

      [quote]
      #{model.body}
      [/quote]
    EOS
  end

  def create_forum_post!
    updater = ForumUpdater.new(forum_topic)
    updater.update(forum_post_message)
  end

  def autoban_reported_user
    if SpamDetector.is_spammer?(reported_user)
      SpamDetector.ban_spammer!(reported_user)
    end
  end

  def reported_user
    case model
    when Comment, ForumPost
      model.creator
    when Dmail
      model.from
    else
      raise NotImplementedError
    end
  end

  def self.visible(user)
    user.is_moderator? ? all : none
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :reason)
    q = q.text_attribute_matches(:reason, params[:reason_matches])

    q.apply_default_order(params)
  end

  def self.searchable_includes
    [:creator, :model]
  end

  def self.available_includes
    [:creator, :model]
  end
end
