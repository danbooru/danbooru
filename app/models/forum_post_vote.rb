class ForumPostVote < ApplicationRecord
  belongs_to_creator
  belongs_to :forum_post
  validates :creator_id, uniqueness: {scope: :forum_post_id}
  validates :score, inclusion: {in: [-1, 0, 1]}
  scope :up, -> {where(score: 1)}
  scope :down, -> {where(score: -1)}
  scope :by, ->(user_id) {where(creator_id: user_id)}
  scope :excluding_user, ->(user_id) {where("creator_id <> ?", user_id)}

  def up?
    score == 1
  end

  def down?
    score == -1
  end

  def meh?
    score == 0
  end

  def fa_class
    if score == 1
      return "fa-thumbs-up"
    elsif score == -1
      return "fa-thumbs-down"
    else
      return "fa-meh"
    end
  end

  def vote_type
    if score == 1
      return "up"
    elsif score == -1
      return "down"
    elsif score == 0
      return "meh"
    else
      raise
    end
  end
end
