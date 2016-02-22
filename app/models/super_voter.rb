class SuperVoter < ActiveRecord::Base
  MAGNITUDE = 5
  DURATION = 1.week

  belongs_to :user
  validates_uniqueness_of :user_id
  after_create :update_user_on_create
  after_destroy :update_user_on_destroy

  def self.prune!
    where("created_at < ?", DURATION.ago).destroy_all
  end

  def self.init!
    report = Reports::UserSimilarity.new(User.admins.first.id)
    report.prime
    report.fetch_similar_user_ids.scan(/\S+/).in_groups_of(2).each do |user_id, score|
      unless where("user_id = ?", user_id.to_i).exists?
        create(:user_id => user_id)
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
