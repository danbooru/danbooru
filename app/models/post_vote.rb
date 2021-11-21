class PostVote < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :user_id, uniqueness: { scope: :post_id, message: "have already voted for this post" }
  validates :score, inclusion: { in: [1, -1], message: "must be 1 or -1" }

  after_create :update_score_after_create
  after_destroy :update_score_after_destroy

  scope :positive, -> { where("post_votes.score > 0") }
  scope :negative, -> { where("post_votes.score < 0") }
  scope :public_votes, -> { positive.where(user: User.has_public_favorites) }

  deletable

  def self.visible(user)
    user.is_admin? ? all : where(user: user).or(public_votes)
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :score, :user, :post)

    q.apply_default_order(params)
  end

  def is_positive?
    score > 0
  end

  def is_negative?
    score < 0
  end

  def update_score_after_create
    if is_positive?
      Post.update_counters(post_id, { score: score, up_score: score })
    else
      Post.update_counters(post_id, { score: score, down_score: score })
    end
  end

  def update_score_after_destroy
    if is_positive?
      Post.update_counters(post_id, { score: -score, up_score: -score })
    else
      Post.update_counters(post_id, { score: -score, down_score: -score })
    end
  end

  def self.available_includes
    [:user, :post]
  end
end
