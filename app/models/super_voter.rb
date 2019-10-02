class SuperVoter < ApplicationRecord
  MAGNITUDE = 3
  DURATION = 1.week

  belongs_to :user
  validates_uniqueness_of :user_id
  after_create :update_user_on_create
  after_destroy :update_user_on_destroy

  def self.prune!
    where("created_at < ?", DURATION.ago).destroy_all
  end

  def self.init!
    prune!

    report = PostVoteSimilarity.new(User.admins.first.id)

    report.calculate_positive(15).each do |element|
      unless SuperVoter.where("user_id = ?", element.user_id).exists?
        SuperVoter.create(:user_id => element.user_id)
      end
    end
  end

  def update_user_on_create
    user.is_super_voter = true
    user.save
  end

  def update_user_on_destroy
    user.is_super_voter = false
    user.save
  end
end
