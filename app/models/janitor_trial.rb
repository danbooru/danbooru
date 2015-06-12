class JanitorTrial < ActiveRecord::Base
  belongs_to :user
  before_create :initialize_original_level
  after_create :send_dmail
  after_create :promote_user
  validates_presence_of :user
  before_validation :initialize_creator
  attr_accessible :user_id

  def self.search(params)
    q = where("true")
    return q if params.blank?

    if params[:user_name]
      q = q.where("user_id = (select _.id from users _ where lower(_.name) = ?)", params[:user_name].mb_chars.downcase)
    end

    if params[:user_id]
      q = q.where("user_id = ?", params[:user_id].to_i)
    end

    q
  end

  def self.message_candidates!
    admin = User.admins.first

    User.where("last_logged_in_at >= ? and created_at <= ? and email is not null and favorite_count >= 200 and level between ? and ?", 1.week.ago, 6.months.ago, User::Levels::MEMBER, User::Levels::CONTRIBUTOR).order("random()").limit(5).each do |user|
      if !Dmail.where("from_id = ? and to_id = ? and title = ?", admin.id, user.id, "Test Janitor Invitation").exists?
        favorites = user.favorites.order("random()").limit(400)
        p50 = ActiveRecord::Base.select_value_sql("select percentile_cont(0.50) within group (order by score) from posts where id in (?)", favorites.map(&:post_id)).to_f

        if p50 > 3 and p50 <= 10
          CurrentUser.scoped(admin, "127.0.0.1") do
            body = <<-EOS
              Janitors on #{Danbooru.config.app_name} are responsible for helping maintain a high level of quality on the site. They approve uploads from other users and help with other moderation efforts. You would be expected at a minimum to approve a few posts a week. If you are interested, please respond to this message.
            EOS

            Dmail.create_split(:title => "Test Janitor Invitation", :body => body, :to_id => user_id, :from_id => admin.id)
          end
        end
      end
    end
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
    body = "You have been selected as a test janitor. You can now approve pending posts and have access to the moderation interface. You should reacquaint yourself with the [[howto:upload]] guide to make sure you understand the site rules.\n\nOver the next several weeks your approvals will be monitored. If the majority of them are quality uploads, then you will be promoted to full janitor status which grants you the ability to delete and undelete posts, ban users, and revert tag changes from vandals. If you fail the trial period, you will be demoted back to your original level and you'll receive a negative user record indicating you previously attempted and failed a test janitor trial.\n\nThere is a minimum quota of 1 approval a month to indicate that you are being active. Remember, the goal isn't to approve as much as possible. It's to filter out borderline-quality art.\n\nIf you have any questions please respond to this message."

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
