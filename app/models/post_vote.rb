class PostVote < ApplicationRecord
  class Error < StandardError; end

  belongs_to :post
  belongs_to :user
  attr_accessor :vote

  after_initialize :initialize_attributes, if: :new_record?
  validates_presence_of :score
  validates_inclusion_of :score, :in => [SuperVoter::MAGNITUDE, 1, -1, -SuperVoter::MAGNITUDE]
  after_create :update_post_on_create
  after_destroy :update_post_on_destroy

  scope :positive, -> { where("post_votes.score > 0") }
  scope :negative, -> { where("post_votes.score < 0") }

  def self.positive_user_ids
    positive.group(:user_id).having("count(*) > 100").pluck(:user_id)
  end

  def self.negative_post_ids(user_id)
    negative.where(user_id: user_id).pluck(:post_id)
  end

  def self.positive_post_ids(user_id)
    positive.where(user_id: user_id).pluck(:post_id)
  end

  def self.visible(user = CurrentUser.user)
    return all if user.is_admin?
    where(user: user)
  end

  def self.search(params)
    q = super
    q = q.visible
    q = q.search_attributes(params, :post, :user, :score)
    q.apply_default_order(params)
  end

  def initialize_attributes
    self.user_id ||= CurrentUser.user.id

    if vote == "up"
      self.score = magnitude
    elsif vote == "down"
      self.score = -magnitude
    end
  end

  def update_post_on_create
    if score > 0
      Post.where(:id => post_id).update_all("score = score + #{score}, up_score = up_score + #{score}")
    else
      Post.where(:id => post_id).update_all("score = score + #{score}, down_score = down_score + #{score}")
    end
  end

  def update_post_on_destroy
    if score > 0
      Post.where(:id => post_id).update_all("score = score - #{score}, up_score = up_score - #{score}")
    else
      Post.where(:id => post_id).update_all("score = score - #{score}, down_score = down_score - #{score}")
    end
  end

  def magnitude
    if user.is_super_voter?
      SuperVoter::MAGNITUDE
    else
      1
    end
  end

  def self.available_includes
    [:user, :post]
  end
end
