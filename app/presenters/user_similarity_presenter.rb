class UserSimilarityPresenter
  attr_reader :report, :user_ids, :not_ready

  def initialize(report)
    @report = report
    fetch
  end

  def not_ready?
    not_ready
  end

  def insufficient_data?
    report.user.favorite_count < 500
  end

  def fetch
    user_ids = report.fetch_similar_user_ids

    if user_ids == "not ready"
      @not_ready = true
    else
      @user_ids = user_ids.scan(/\d+/).slice(0, 10)
    end
  end

  def each_user(&block)
    User.where(id: user_ids).each(&block)
  end

  def each_favorite_for(user, &block)
    user.favorites.limit(6).joins(:post).reorder("favorites.id desc").map(&:post).each(&block)
  end
end
