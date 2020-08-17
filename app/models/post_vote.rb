class PostVote < ApplicationRecord
  class Error < StandardError; end

  belongs_to :post
  belongs_to :user
  attr_accessor :vote

  after_initialize :initialize_attributes, if: :new_record?
  validates_presence_of :score
  validates_inclusion_of :score, in: [1, -1]
  after_create :update_post_on_create
  after_destroy :update_post_on_destroy

  scope :positive, -> { where("post_votes.score > 0") }
  scope :negative, -> { where("post_votes.score < 0") }

  def self.visible(user)
    user.is_admin? ? all : where(user: user)
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :score)
    q.apply_default_order(params)
  end

  def initialize_attributes
    self.user_id ||= CurrentUser.id

    if vote == "up"
      self.score = 1
    elsif vote == "down"
      self.score = -1
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

  def self.searchable_includes
    [:user, :post]
  end

  def self.available_includes
    [:user, :post]
  end
end
