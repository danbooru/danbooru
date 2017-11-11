module PostSets
  class MostViewed < PostSets::Base
    attr_reader :date

    def initialize(date)
      @date = date.blank? ? Date.today : Date.parse(date)
    end

    def posts
      @posts ||= PostViewCountService.new.popular_posts(date)
    end

    def presenter
      ::PostSetPresenters::MostViewed.new(self)
    end
  end
end
