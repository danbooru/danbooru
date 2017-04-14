require "set"

class PostVoteSimilarity
  THRESHOLD = 0.035

  class Element
    attr_reader :user_id, :score

    def initialize(user_id, score)
      @user_id = user_id
      @score = score
    end

    def <=>(rhs)
      score <=> rhs.score
    end
  end

  attr_reader :user_id

  def initialize(user_id)
    @user_id = user_id
  end

  # returns user ids with strong positive correlation
  def calculate_positive(limit = 10)
    posts0 = PostVote.positive_post_ids(user_id)
    set = []

    PostVote.positive_user_ids.each do |uid|
      posts1 = PostVote.positive_post_ids(uid)
      score = calculate_with_jaccard(posts0, posts1)
      if score >= THRESHOLD
        set << Element.new(uid, score)
      end
    end

    set.sort.reverse.first(limit)
  end

  def calculate_with_jaccard(posts0, posts1)
    a = (posts0 & posts1).size
    div = posts0.size + posts1.size - a
    if div == 0
      0
    else
      a / div.to_f
    end
  end

  def calculate_with_cosine(posts0, posts1)
    a = (posts0 & posts1).size
    div = Math.sqrt(posts0.size * posts1.size)
    if div == 0
      0
    else
      a / div
    end
  end
end
