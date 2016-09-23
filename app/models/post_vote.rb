class PostVote < ActiveRecord::Base
  class Error < Exception ; end

  belongs_to :post
  before_validation :initialize_user, :on => :create
  validates_presence_of :post_id, :user_id, :score
  validates_inclusion_of :score, :in => [SuperVoter::MAGNITUDE, 1, -1, -SuperVoter::MAGNITUDE]
  attr_accessible :post_id, :user_id, :score
  after_destroy :update_post_on_destroy

  def self.prune!
    where("created_at < ?", 90.days.ago).delete_all
  end

  def self.positive_user_ids
    select_values_sql("select user_id from post_votes where score > 0 group by user_id having count(*) > 100")
  end

  def self.negative_post_ids(user_id)
    select_values_sql("select post_id from post_votes where score < 0 and user_id = ?", user_id)
  end

  def self.positive_post_ids(user_id)
    select_values_sql("select post_id from post_votes where score > 0 and user_id = ?", user_id)
  end

  def score=(x)
    if x == "up"
      Post.where(:id => post_id).update_all("score = score + #{magnitude}, up_score = up_score + #{magnitude}")
      write_attribute(:score, magnitude)
    elsif x == "down"
      Post.where(:id => post_id).update_all("score = score - #{magnitude}, down_score = down_score - #{magnitude}")
      write_attribute(:score, -magnitude)
    end
  end

  def initialize_user
    self.user_id = CurrentUser.user.id
  end

  def update_post_on_destroy
    if score > 0
      Post.where(:id => post_id).update_all("score = score - #{score}, up_score = up_score - #{score}")
    else
      Post.where(:id => post_id).update_all("score = score - #{score}, down_score = down_score - #{score}")
    end
  end

  def magnitude
    if CurrentUser.is_super_voter?
      SuperVoter::MAGNITUDE
    else
      1
    end
  end
end
