module PostSets
  class Favorite < Base
    attr_reader :user, :page, :favorites
    
    def initialize(user_id, page = 1)
      @user = ::User.find(user_id)
      @favorites = ::Favorite.for_user(user.id).paginate(page)
    end
    
    def tag_array
      @tag_array ||= ["fav:#{user.name}"]
    end
    
    def tag_string
      tag_array.join(" ")
    end
    
    def posts
      favorites.order("favorites.id desc").includes(:post).map(&:post)
    end
    
    def presenter
      @presenter ||= ::PostSetPresenters::Favorite.new(self)
    end
  end
end
