module PostSets
  class FavoriteSet < Base
    attr_accessor :user

    def initialize(options = {})
      super(options)
      @user = user
    end
    
    def tags
      "fav:#{user.name}"
    end

    def load_posts
      user.favorite_posts(:before_id => before_id)
    end
  end  
end
