class UserMailer < ActionMailer::Base
  add_template_helper ApplicationHelper
  add_template_helper UsersHelper
  default :from => Danbooru.config.contact_email, :content_type => "text/html"

  def dmail_notice(dmail)
    @dmail = dmail
    mail(:to => "#{dmail.to.name} <#{dmail.to.email}>", :subject => "#{Danbooru.config.app_name} - Message received from #{dmail.from.name}")
  end

  def forum_notice(user, forum_topic, forum_posts)
    @user = user
    @forum_topic = forum_topic
    @forum_posts = forum_posts
    mail(:to => "#{user.name} <#{user.email}>", :subject => "#{Danbooru.config.app_name} forum topic #{forum_topic.title} updated")
  end
end
