class UserSimilarityPresenter
  attr_reader :report, :user_ids, :user_ids_with_scores, :not_ready

  def initialize(report)
    @report = report
    fetch
  end

  def not_ready?
    not_ready
  end

  def insufficient_data?
    report.user.favorite_count < 200
  end

  def fetch
    data = report.fetch_similar_user_ids

    if data == "not ready"
      @not_ready = true
    else
      @user_ids_with_scores = data.scan(/\S+/).in_groups_of(2)
    end
  end

  def user_ids
    user_ids_with_scores.map(&:first)
  end

  def scores
    user_ids_with_scores.map(&:last)
  end

  def each_user(&block)
    user_ids_with_scores.each do |user_id, score|
      yield(User.find(user_id), 100 * score.to_f)
    end
  end

  def each_favorite_for(user, &block)
    user.favorites.limit(18).joins(:post).reorder("favorites.id desc").map(&:post).each(&block)
  end
end
