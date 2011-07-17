class UserMaintenanceMailer < ActionMailer::Base
  default :from => Danbooru.config.contact_email
  
  
  def reset_password(user, new_password)
    @user = user
    @new_password = new_password
    mail(:to => user.email, :subject => "#{Danbooru.config.app_name} password reset")
  end
end
