# rdoc
#   A tag set represents a set of tags that are displayed together.
#   This class makes it easy to fetch the categories for all the
#   tags in one call instead of fetching them sequentially.

class TagSetPresenter
  extend Memoist
  attr_reader :tag_names

  # @param [Array<String>] a list of tags to present. Tags will be presented in
  # the order given. The list should not contain duplicates. The list may
  # contain tags that do not exist in the tags table, such as metatags.
  def initialize(tag_names)
    @tag_names = tag_names
  end

  def tag_list_html(current_query: "", show_extra_links: false, name_only: false)
    html = ""

    if ordered_tags.present?
      html << '<ul>'
      ordered_tags.each do |tag|
        html << build_list_item(tag, current_query: current_query, show_extra_links: show_extra_links, name_only: name_only)
      end
      html << "</ul>"
    end

    html.html_safe
  end

  def split_tag_list_html(headers: true, category_list: TagCategory.split_header_list, current_query: "", show_extra_links: false, name_only: false, humanize_tags: true)
    html = ""

    category_list.each do |category|
      typetags = tags_for_category(category)

      if typetags.any?
        if headers
          html << %{<h3 class="#{category}-tag-list">#{category.capitalize.pluralize(typetags.size)}</h3>}
        end

        html << %{<ul class="#{category}-tag-list">}
        typetags.each do |tag|
          html << build_list_item(tag, current_query: current_query, show_extra_links: show_extra_links, name_only: name_only, humanize_tags: humanize_tags)
        end
        html << "</ul>"
      end
    end

    html.html_safe
  end

  # compact (horizontal) list, as seen in the /comments index.
  def inline_tag_list_html(humanize_tags: false)
    html = split_tag_list_html(category_list: TagCategory.categorized_list, headers: false, show_extra_links: false, name_only: true, humanize_tags: humanize_tags)
    %{<span class="inline-tag-list">#{html}</span>}.html_safe
  end

  # the list of tags inside the tag box in the post edit form.
  def split_tag_list_text(category_list: TagCategory.categorized_list)
    category_list.map do |category|
      tags_for_category(category).map(&:name).join(" ")
    end.reject(&:blank?).join(" \n")
  end

  def humanized_essential_tag_string(default: "")
    chartags = tags_for_category("character")
    characters = chartags.max_by(5, &:post_count).map(&:unqualified_name)
    characters += ["#{chartags.size - 5} more"] if chartags.size > 5
    characters = characters.to_sentence

    copytags = tags_for_category("copyright")
    copyrights = copytags.max_by(1, &:post_count).map(&:unqualified_name)
    copyrights += ["#{copytags.size - 1} more"] if copytags.size > 1
    copyrights = copyrights.to_sentence
    copyrights = "(#{copyrights})" if characters.present?

    artists = tags_for_category("artist").map(&:name).grep_v("banned_artist").to_sentence
    artists = "drawn by #{artists}" if artists.present?

    strings = "#{characters} #{copyrights} #{artists}"
    strings.presence || default
  end

  private

  def tags
    Tag.where(name: tag_names).select(:name, :post_count, :category)
  end

  def tags_by_category
    ordered_tags.group_by(&:category)
  end

  def tags_for_category(category_name)
    category = TagCategory.mapping[category_name.downcase]
    tags_by_category[category] || []
  end

  def ordered_tags
    names_to_tags = tags.map { |tag| [tag.name, tag] }.to_h

    tag_names.map do |name|
      names_to_tags[name] || Tag.new(name: name).freeze
    end
  end

  def build_list_item(tag, name_only: false, humanize_tags: true, show_extra_links: false, current_query: "")
    name = tag.name
    count = tag.post_count
    category = tag.category

    html = %{<li class="tag-type-#{tag.category}" data-tag-name="#{h(name)}">}

    unless name_only
      if tag.artist?
        html << %{<a class="wiki-link" href="/artists/show_or_new?name=#{u(name)}">?</a> }
      elsif name =~ /\A\d+\z/
        html << %{<a class="wiki-link" href="/wiki_pages/~#{u(name)}">?</a> }
      else
        html << %{<a class="wiki-link" href="/wiki_pages/#{u(name)}">?</a> }
      end

      if show_extra_links && current_query.present?
        html << %{<a href="/posts?tags=#{u(current_query)}+#{u(name)}" class="search-inc-tag">+</a> }
        html << %{<a href="/posts?tags=#{u(current_query)}+-#{u(name)}" class="search-exl-tag">&ndash;</a> }
      end
    end

    humanized_tag = humanize_tags ? name.tr("_", " ") : name
    html << %{<a class="search-tag" href="/posts?tags=#{u(name)}">#{h(humanized_tag)}</a> }

    unless name_only || tag.new_record?
      if count >= 10_000
        post_count = "#{count / 1_000}k"
      elsif count >= 1_000
        post_count = format("%.1fk", (count / 1_000.0))
      else
        post_count = count
      end

      is_underused_tag = count <= 1 && tag.general?
      klass = "post-count#{is_underused_tag ? " low-post-count" : ""}"

      html << %{<span class="#{klass}" title="#{count}">#{post_count}</span>}
    end

    html << "</li>"
    html
  end

  def h(s)
    CGI.escapeHTML(s)
  end

  def u(s)
    CGI.escape(s)
  end

  memoize :tags, :tags_by_category, :ordered_tags, :humanized_essential_tag_string
end
