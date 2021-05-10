Rails.application.reloader.to_prepare do
  ActiveRecord::Type.register(:ip_address, IpAddressType)
end
