class JanitorTrial < ActiveRecord::Base
  belongs_to :user
  before_create :initialize_original_level
  after_create :send_dmail
  after_create :promote_user
  validates_presence_of :user
  before_validation :initialize_creator

  def self.search(params)
    q = scoped
    return q if params.blank?

    if params[:user_name]
      q = q.where("user_id = (select _.id from users _ where lower(_.name) = ?)", params[:user_name].mb_chars.downcase)
    end

    if params[:user_id]
      q = q.where("user_id = ?", params[:user_id].to_i)
    end

    q
  end

  def initialize_creator
    self.creator_id = CurrentUser.id
  end

  def initialize_original_level
    self.original_level = user.level
  end

  def user_name
    user.try(:name)
  end

  def user_name=(name)
    self.user_id = User.name_to_id(name)
  end

  def send_dmail
    body = "You have been selected as a test janitor. You can now approve pending posts and have access to the moderation interface.\n\nOver the next several weeks your approvals will be monitored. If the majority of them are quality uploads, then you will be promoted to full janitor status which grants you the ability to delete and undelete posts, ban users, and revert tag changes from vandals. If you fail the trial period, you will be demoted back to your original level and you'll receive a negative user record indicating you previously attempted and failed a test janitor trial.\n\nThere is a minimum quota of 5 approvals a week to indicate that you are being active. Remember, the goal isn't to approve as much as possible. It's to filter out borderline-quality art.\n\nIf you have any questions please respond to this message."

    Dmail.create_split(:title => "Test Janitor Trial Period", :body => body, :to_id => user_id)
  end

  def promote_user
    user.update_column(:level, User::Levels::JANITOR)
  end

  def create_feedback
    user.feedback.create(
      :category => "negative",
      :body => "Demoted from janitor trial"
    )
  end

  def promote!
    destroy
  end

  def demote!
    user.update_column(:level, original_level)
    self.create_feedback
    destroy
  end
end
