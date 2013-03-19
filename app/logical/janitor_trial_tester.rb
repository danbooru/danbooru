class JanitorTrialTester
  attr_reader :user

  def initialize(user_name)
    @user = User.find_by_name(user_name)
  end

  def test
    if user.nil?
      "User not found"
    elsif user.created_at > 1.month.ago
      "User signed up within the past month"
    elsif user.favorites.count < 100
      "User has fewer than 100 favorites"
    elsif user.feedback.negative.count > 0
      "User has negative feedback"
    else
      "No issues found"
    end
  end
end
