module DmailsHelper
  def dmails_current_folder_path
    case cookies[:dmail_folder]
    when "sent"
      sent_dmails_path
    when "received"
      received_dmails_path
    else
      all_dmails_path
    end
  end

  def all_dmails_path(params = {})
    dmails_path(folder: "all", **params)
  end

  def sent_dmails_path(params = {})
    dmails_path(search: {from_id: CurrentUser.id}, folder: "sent", **params)
  end

  def spam_dmails_path
    dmails_path(search: {to_id: CurrentUser.id, is_spam: true}, folder: "spam")
  end

  def received_dmails_path(params = {})
    dmails_path(search: {to_id: CurrentUser.id}, folder: "received", **params)
  end
end
