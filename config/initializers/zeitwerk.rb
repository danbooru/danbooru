Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "apng_inspector" => "APNGInspector",
    "sftp" => "SFTP"
  )
end
