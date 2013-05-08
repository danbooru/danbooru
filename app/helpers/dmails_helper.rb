module DmailsHelper
  def dmails_current_folder_path
    case cookies[:dmail_folder]
    when "sent"
      dmails_path(:search => {:owner_id => CurrentUser.id, :from_id => CurrentUser.id}, :folder => "sent")
    when "all"
      dmails_path(:search => {:owner_id => CurrentUser.id}, :folder => "all")
    else
      dmails_path(:search => {:owner_id => CurrentUser.id, :to_id => CurrentUser.id}, :folder => "received")
    end
  end
end
