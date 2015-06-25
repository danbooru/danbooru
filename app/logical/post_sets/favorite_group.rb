module PostSets
  class FavoriteGroup < PostSets::Pool
    def presenter
      @presenter ||= PostSetPresenters::FavoriteGroup.new(self)
    end
  end
end
