module PostSets
  class Favorite < Base
    attr_reader :user, :page, :favorites, :params

    def initialize(user_id, page = 1, params = {})
      @params = params
      @user = ::User.find(user_id)
      @favorites = ::Favorite.for_user(user.id).paginate(page, :limit => limit).order("favorites.id desc")

      if CurrentUser.user.hide_deleted_posts?
        @favorites = @favorites.where("is_deleted = false")
      end
    end

    def limit
      params[:limit] || CurrentUser.user.per_page
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
