module PostSets
  module Favorite
    def user
      @user ||= ::User.find(params[:id])
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
      @count ||= relation.count
    end

    def posts
      @posts ||= slice(relation).map(&:post)
    end
    
    def relation
      ::Favorite.model_for(user.id).where("user_id = ?", user.id).order("id desc")
    end
  end  
end
