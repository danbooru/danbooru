class JanitorTrial < ApplicationRecord
  belongs_to :user
  after_create :send_dmail
  after_create :promote_user
  validates_presence_of :user
  belongs_to_creator
  validates_inclusion_of :status, :in => %w(active inactive)
  before_validation :initialize_status
  validates_uniqueness_of :user_id

  def self.search(params)
    q = super.where(status: "active")

    if params[:user_name]
      q = q.where("user_id = (select _.id from users _ where lower(_.name) = ?)", params[:user_name].mb_chars.downcase)
    end

    if params[:user_id]
      q = q.where("user_id = ?", params[:user_id].to_i)
    end

    q.apply_default_order(params)
  end

  def self.message_candidates!
    admin = User.admins.first
    n = 0

    User.without_timeout do
      User.where("last_logged_in_at >= ? and created_at <= ? and email is not null and (favorite_count >= 300 OR post_upload_count >= 300) and bit_prefs & ? = 0", 1.week.ago, 6.months.ago, User.flag_value_for("can_approve_posts")).find_each do |user|
        if !Dmail.where("from_id = ? and to_id = ? and title = ?", admin.id, user.id, "Test Janitor Invitation").exists?
          favorites = user.favorites.order("random()").limit(400).map(&:post_id)
          uploads = user.posts.order("random()").limit(400).map(&:id)
          p50 = ActiveRecord::Base.select_value_sql("select percentile_cont(0.50) within group (order by score) from posts where id in (?)", favorites + uploads).to_f
          
          if p50 > 3
            n += 1
            if n > 8
              break
            end

            CurrentUser.scoped(admin, "127.0.0.1") do
              body = <<-EOS
                Janitors on #{Danbooru.config.app_name} are responsible for helping maintain a high level of quality on the site. They approve uploads from other users and help with other moderation efforts. You would be expected at a minimum to approve a few posts a week. If you are interested, please respond to this message.
              EOS

              Dmail.create_split(:title => "Test Janitor Invitation", :body => body, :to_id => user.id)
            end
          end
        end
      end
    end
  end

  def initialize_status
    self.status = "active"
  end

  def user_name
    user.try(:name)
  end

  def user_name=(name)
    self.user_id = User.name_to_id(name)
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
      :category => "negative",
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
