class UserDeletion
  class ValidationError < Exception ; end

  attr_reader :user, :password

  def initialize(user, password)
    @user = user
    @password = password
  end

  def delete!
    validate
    clear_user_settings
    remove_favorites
    rename
    reset_password
  end

private

  def clear_user_settings
    user.email = nil
    user.last_logged_in_at = nil
    user.last_forum_read_at = nil
    user.recent_tags = nil
    user.favorite_tags = nil
    user.blacklisted_tags = nil
    user.hide_deleted_posts = false
    user.time_zone = "Eastern Time (US & Canada)"
    user.save!
  end

  def reset_password
    random = SecureRandom.hex(16)
    user.password = random
    user.password_confirmation = random
    user.old_password = password
    user.save!
  end

  def remove_favorites
    Post.tag_match("fav:#{user.name}").find_each do |post|
      Favorite.remove(post, user)
    end
  end

  def rename
    name = "user_#{user.id}"
    n = 0
    while User.where(:name => name).exists? && (n < 10)
      name += "~"
    end

    if n == 10
      raise ValidationError.new("New name could not be found")
    end

    user.name = name
    user.save!
  end

  def validate
    if !User.authenticate(user.name, password)
      raise ValidationError.new("Password is incorrect")
    end

    if user.level >= User::Levels::ADMIN
      raise ValidationError.new("Admins cannot delete their account")
    end
  end
end
