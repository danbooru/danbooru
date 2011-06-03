module PostSets
  module Favorite
    def user
      @user ||= User.find(params[:id])
    end
    
    def tags
      @tags ||= ["fav:#{user.name}"]
    end
    
    def has_wiki?
      false
    end
    
    def reload
      super
      @user = nil
      @count = nil
    end
    
    def count
      @count ||= Favorite.count(user.id)
    end

    def posts
      @posts ||= user.favorites(pagination_options)
    end
  end  
end
