class UserMailerPreview < ActionMailer::Preview
  def dmail_notice
    dmail = User.admins.first.dmails.first
    UserMailer.dmail_notice(dmail)
  end

  def forum_notice
    topic = ForumTopic.first
    posts = topic.posts
    user = topic.creator

    UserMailer.forum_notice(user, topic, posts)
  end
end
