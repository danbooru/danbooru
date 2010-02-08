ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'shoulda'
require 'factory_girl'
require 'mocha'
require 'faker'
require 'rails/test_help'

Dir[File.expand_path(File.dirname(__FILE__) + "/factories/*.rb")].each {|file| require file}

class ActiveSupport::TestCase
protected
  def upload_file(path, content_type, filename)
  	tempfile = Tempfile.new(filename)
  	FileUtils.copy_file(path, tempfile.path)
  	(class << tempfile; self; end).class_eval do
  		alias local_path path
  		define_method(:original_filename) {filename}
  		define_method(:content_type) {content_type}
  	end

  	tempfile
  end

  def upload_jpeg(path)
  	upload_file(path, "image/jpeg", File.basename(path))
  end
end
