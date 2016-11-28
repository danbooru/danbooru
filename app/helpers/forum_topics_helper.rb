module ForumTopicsHelper
  def forum_topic_category_select(object, field)
    select(object, field, ForumTopic.reverse_category_mapping.to_a)
  end

  def available_min_user_levels
    if CurrentUser.is_admin?
      [["Moderator", User::Levels::MODERATOR], ["Admin", User::Levels::ADMIN]]
    elsif CurrentUser.is_moderator?
      [["Moderator", User::Levels::MODERATOR]]
    else
      []
    end
  end
end
