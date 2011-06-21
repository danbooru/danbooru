module PostSets
  class Favorite < Base
    attr_reader :user, :page, :favorites, :posts
    
    def initialize(user_id, page)
      @user = ::User.find(user_id)
      @page = [page.to_i, 1].max
      @favorites = ::Favorite.model_for(user.id).for_user(user.id).page(page)
      @posts = ::Post.where("id in (?)", post_ids).order(arbitrary_sql_order_clause(post_ids, "posts")).page("b0")
    end
    
    def post_ids
      @post_ids ||= favorites.map(&:post_id)
    end
    
    def offset
      (page - 1) * records_per_page
    end
    
    def tag_array
      @tag_array ||= ["fav:#{user.name}"]
    end
    
    def tag_string
      tag_array.join(" ")
    end
  end
end
