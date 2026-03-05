# frozen_string_literal: true

module WikiPagesHelper
  def wiki_page_other_names_list(wiki_page)
    html = wiki_page.other_names.map do |name|
      render ExternalTagLinkComponent.new(name)
    end

    tag.div safe_join(html, " "), class: "flex gap-1 flex-wrap"
  end
end
