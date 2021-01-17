module WikiPagesHelper
  def wiki_page_other_names_list(wiki_page)
    names_html = wiki_page.other_names.map {|name| link_to(name, "http://www.pixiv.net/search.php?s_mode=s_tag_full&word=#{u(name)}", :class => "wiki-other-name")}
    names_html.join(" ").html_safe
  end

  def wiki_page_redirect(wiki_page)
    if wiki_page.wiki_redirect.present?
      "yes"
    elsif wiki_page.redirect_title
      "no wiki"
    end
  end
end
