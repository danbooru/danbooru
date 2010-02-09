class Post < ActiveRecord::Base
  class Deletion < ActiveRecord::Base
    set_table_name "deleted_posts"
  end

  def file_path
    prefix = Rails.env == "test" ? "test." : ""
    "#{Rails.root}/public/data/original/#{prefix}#{md5}.#{file_ext}"
  end
end
