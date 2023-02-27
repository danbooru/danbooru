Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect({})
end

Rails.autoloaders.logger = Rails.logger
