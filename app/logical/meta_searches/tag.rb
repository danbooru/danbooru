class MetaSearches::Tag
  MAX_RESULTS = 25
  attr_reader :search_params, :tags, :tag_aliases, :tag_implications

  def initialize(search_params)
    @search_params = search_params
  end

  def load_all
    load_tags
    load_tag_aliases
    load_tag_implications
  end

  def load_tags
    @tags = ::Tag.name_matches(name_param).limit(MAX_RESULTS)
  end

  def load_tag_aliases
    @tag_aliases = TagAlias.name_matches(name_param).limit(MAX_RESULTS)
  end

  def load_tag_implications
    @tag_implications = TagImplication.name_matches(name_param).limit(MAX_RESULTS)
  end

  def name_param
    search_params[:name] || ""
  end
end
