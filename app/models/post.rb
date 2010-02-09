class Post < ActiveRecord::Base
  class Deletion < ActiveRecord::Base
    set_table_name "deleted_posts"
  end
  
end
