class ApplicationComponent < ViewComponent::Base
  def policy(subject)
    Pundit.policy!(current_user, subject)
  end
end
