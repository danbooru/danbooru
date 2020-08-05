module LinkedAccountHelper
  def linked_account_logo_url(site_name)
    case site_name
    when "Discord"
      "/images/discord-logo-512px.png"
    when "DeviantArt"
      "/images/deviantart-logo-512px.png"
    end
  end
end
