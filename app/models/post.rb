class Post < ActiveRecord::Base
  def file_path
    prefix = Rails.env == "test" ? "test." : ""
    "#{Rails.root}/public/data/original/#{prefix}#{md5}.#{file_ext}"
  end
end
