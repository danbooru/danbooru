class IntroPresenter
  def popular_tags
    Tag.where("category = 3").order("post_count desc").limit(8).map(&:name)
  end

  def each
    popular_tags.each do |tag|
      yield(tag, PostSets::Intro.new(tag))
    end
  end
end
