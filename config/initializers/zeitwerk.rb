Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "sftp" => "SFTP"
  )
end
