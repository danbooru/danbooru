class SessionCreator
  attr_reader :session, :cookies, :name, :password, :remember, :secure

  def initialize(session, cookies, name, password, remember = false, secure = false)
    @session = session
    @cookies = cookies
    @name = name
    @password = password
    @remember = remember
    @secure = secure
  end

  def authenticate
    if User.authenticate(name, password)
      user = User.find_by_name(name)
      user.update_column(:last_forum_read_at, user.last_logged_in_at)
      user.update_column(:last_logged_in_at, Time.now)

      if remember.present?
        cookies.permanent.signed[:user_name] = {
          :value => user.name,
          :secure => secure
        }
        cookies.permanent[:password_hash] = {
          :value => user.bcrypt_cookie_password_hash,
          :secure => secure,
          :httponly => true
        }
      end

      session[:user_id] = user.id
      prune_read_forum_topics(user)
      return true
    else
      return false
    end
  end

  def prune_read_forum_topics(user)
    # if user.last_forum_read_at
    #   read_forum_topic_ids = session[:read_forum_topics].to_s.scan(/\S+/)
    #   session[:read_forum_topics] = read_forum_topic_ids.select {|x| ForumTopic.where("updated_at >= ? and id = ?", user.last_forum_read_at, x).exists?}.join(" ")
    # end
  end
end
