module PostSets
  class Favorite < Base
    attr_reader :user, :page, :favorites, :posts
    
    def initialize(params)
      @user = ::User.find(params[:id])
      @page = [params[:page].to_i, 1].max
      @favorites = ::Favorite.model_for(@user.id).for_user(@user.id).paginate(page)
      @posts = ::Post.where("id in (?)", post_ids).order(arbitrary_sql_order_clause(post_ids, "posts")).paginate("a0")
    end
    
    def post_ids
      @post_ids ||= favorites.map(&:post_id)
    end
    
    def offset
      (page - 1) * records_per_page
    end
    
    def tag_string
      @tag_string ||= "fav:#{user.name}"
    end
  end
end
