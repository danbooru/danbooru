module PostSets
  class Favorite < Base
    attr_reader :user, :page, :favorites
    
    def initialize(user_id, page = 1)
      @user = ::User.find(user_id)
      @favorites = ::Favorite.for_user(user.id).paginate(page).order("favorites.id desc")
    end
    
    def tag_array
      @tag_array ||= ["fav:#{user.name}"]
    end
    
    def tag_string
      tag_array.uniq.join(" ")
    end
    
    def humanized_tag_string
      "fav:#{user.pretty_name}"
    end
    
    def posts
      favorites.includes(:post).map(&:post)
    end
    
    def presenter
      @presenter ||= ::PostSetPresenters::Favorite.new(self)
    end
  end
end
