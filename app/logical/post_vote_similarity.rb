require "set"

class PostVoteSimilarity
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

  # returns user ids with strong negative correlation
  def calculate_negative(limit = 10)
    posts0 = PostVote.negative_post_ids(user_id)
    set = SortedSet.new

    PostVote.positive_user_ids.each do |uid|
      posts1 = PostVote.positive_post_ids(uid)
      set.add(Element.new(uid, calculate_with_cosine(posts0, posts1)))
    end

    set.first(limit)
  end

  # returns user ids with strong positive correlation
  def calculate_positive(limit = 10)
    posts0 = PostVote.positive_post_ids(user_id)
    set = SortedSet.new

    PostVote.positive_user_ids.each do |uid|
      posts1 = PostVote.positive_post_ids(uid)
      set.add(Element.new(uid, calculate_with_cosine(posts0, posts1)))
    end

    set.first(limit)
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
