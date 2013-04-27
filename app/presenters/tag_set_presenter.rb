=begin rdoc
  A tag set represents a set of tags that are displayed together.
  This class makes it easy to fetch the categories for all the
  tags in one call instead of fetching them sequentially.
=end

class TagSetPresenter < Presenter
  def initialize(tags)
    @tags = tags
  end

  def tag_list_html(template, options = {})
    html = ""
    if @tags.present?
      html << "<ul>"
      @tags.each do |tag|
        html << build_list_item(tag, template, options)
      end
      html << "</ul>"
    end

    html.html_safe
  end

  def split_tag_list_html(template, options = {})
    html = ""

    if copyright_tags.any?
      html << '<h2>Copyrights</h2>'
      html << "<ul>"
      copyright_tags.keys.each do |tag|
        html << build_list_item(tag, template, options)
      end
      html << "</ul>"
    end

    if character_tags.any?
      html << '<h2>Characters</h2>'
      html << "<ul>"
      character_tags.keys.each do |tag|
        html << build_list_item(tag, template, options)
      end
      html << "</ul>"
    end

    if artist_tags.any?
      html << '<h2>Artist</h2>'
      html << "<ul>"
      artist_tags.keys.each do |tag|
        html << build_list_item(tag, template, options)
      end
      html << "</ul>"
    end

    if general_tags.any?
      html << '<h1>Tags</h1>'
      html << "<ul>"
      general_tags.keys.each do |tag|
        html << build_list_item(tag, template, options)
      end
      html << "</ul>"
    end

    html.html_safe
  end

private
  def general_tags
    @general_tags ||= categories.select {|k, v| v == Tag.categories.general}
  end

  def copyright_tags
    @copyright_tags ||= categories.select {|k, v| v == Tag.categories.copyright}
  end

  def character_tags
    @character_tags ||= categories.select {|k, v| v == Tag.categories.character}
  end

  def artist_tags
    @artist_tags ||= categories.select {|k, v| v == Tag.categories.artist}
  end

  def categories
    @categories ||= Tag.categories_for(@tags)
  end

  def counts
    @counts ||= Tag.counts_for(@tags).inject({}) do |hash, x|
      hash[x["name"]] = x["post_count"]
      hash
    end
  end

  def is_index?(template)
    template.params[:action] == "index"
  end

  def build_list_item(tag, template, options)
    html = ""
    html << %{<li class="category-#{categories[tag]}">}
    current_query = template.params[:tags] || ""

    unless options[:name_only]
      if categories[tag] == Tag.categories.artist
        html << %{<a class="wiki-link" href="/artists/show_or_new?name=#{u(tag)}">?</a> }
      else
        html << %{<a class="wiki-link" href="/wiki_pages/show_or_new?title=#{u(tag)}">?</a> }
      end

      if CurrentUser.user.is_privileged? && is_index?(template) && current_query.present?
        html << %{<a href="/posts?tags=#{u(current_query)}+#{u(tag)}" class="search-inc-tag">+</a> }
        html << %{<a href="/posts?tags=#{u(current_query)}+-#{u(tag)}" class="search-exl-tag">&ndash;</a> }
      end
    end

    humanized_tag = tag.tr("_", " ")
    path = options[:path_prefix] || "/posts"
    html << %{<a class="search-tag" href="#{path}?tags=#{u(tag)}">#{h(humanized_tag)}</a> }

    unless options[:name_only]
      if counts[tag].to_i > 1_000
        post_count = "#{counts[tag].to_i / 1_000}k"
      else
        post_count = counts[tag].to_s
      end

      is_underused_tag = counts[tag].to_i <= 1 && categories[tag] == Tag.categories.general
      html << %{<span class="post-count#{is_underused_tag ? " low-post-count" : ""}"#{is_underused_tag ? " title='This tag has low post count. Check if it is a typo or consider tagging more post with it.'" : ""}>#{post_count}</span>}
    end

    html << "</li>"
    html
  end
end
