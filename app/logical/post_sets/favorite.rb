module PostSets
  class Favorite < Base
    attr_accessor :user

    def initialize(user)
      @user = user
      super()
    end
    
    def tags
      "fav:#{user.name}"
    end

    def load_posts
      @posts = user.favorite_posts(:before_id => before_id)
    end
  end  
end
