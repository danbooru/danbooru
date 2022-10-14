Rails.application.reloader.to_prepare do
  ActiveRecord::Type.register(:ip_address, IpAddressType)
  ActiveRecord::Type.register(:email_address, EmailAddressType)
end
