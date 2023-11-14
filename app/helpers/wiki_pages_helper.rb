# frozen_string_literal: true

module WikiPagesHelper
  def wiki_page_other_names_list(wiki_page)
    names_html = wiki_page.other_names.map do |name|
      link_to(name, "https://www.pixiv.net/tags/#{u(name)}/artworks", class: "wiki-other-name chip-primary text-sm truncate")
    end

    tag.p safe_join(names_html, " "), class: "flex flex-wrap gap-1"
  end
end
