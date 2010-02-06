require "#{Rails.root}/config/danbooru_default_config"
require "#{Rails.root}/config/danbooru_local_config"

module Danbooru
  def config
    @configuration ||= CustomConfiguration.new
  end
  
  module_function :config
end
