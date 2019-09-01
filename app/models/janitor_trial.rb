class JanitorTrial < ApplicationRecord
  belongs_to :user
  after_create :send_dmail
  after_create :promote_user
  belongs_to_creator
  validates_inclusion_of :status, :in => %w(active inactive)
  before_validation :initialize_status
  validates_uniqueness_of :user_id

  def self.search(params)
    q = super.where(status: "active")
    q = q.search_attributes(params, :user, :creator, :original_level)
    q.apply_default_order(params)
  end

  def initialize_status
    self.status = "active"
  end

  def user_name
    user.try(:name)
  end

  def user_name=(name)
    self.user = User.find_by_name(name)
  end

  def send_dmail
    body = "You have been selected as a test janitor. You can now approve pending posts and have access to the moderation interface. You should reacquaint yourself with the [[howto:upload]] guide to make sure you understand the site rules.\n\nOver the next several weeks your approvals will be monitored. If the majority of them are not quality uploads you will fail the trial period and lose your approval privileges. You will also receive a negative user record indicating you previously attempted and failed a test janitor trial.\n\nThere is a minimum quota of 1 approval a month to indicate that you are being active. Remember, the goal isn't to approve as much as possible. It's to filter out borderline-quality art."

    Dmail.create_automated(:title => "Test Janitor Trial Period", :body => body, :to_id => user_id)
  end

  def promote_user
    user.feedback.create(:category => "neutral", :body => "Gained approval privileges")
    user.can_approve_posts = true
    user.save
  end

  def create_feedback
    user.feedback.create(
      :category => "neutral",
      :body => "Lost approval privileges"
    )
  end

  def promote!
    update_attribute(:status, "inactive")
  end

  def demote!
    user.can_approve_posts = false
    user.save
    update_attribute(:status, "inactive")
    self.create_feedback
  end

  def active?
    status == "active"
  end

  def inactive?
    status == "inactive"
  end
end
