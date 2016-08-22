class IntroPresenter
  def each
    PopularSearchService.new(Date.today, "month").each_search(20) do |query, count|
      yield(query, PostSets::Intro.new(query))
    end
  end
end
