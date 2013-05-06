module WikiPagesHelper
  def wiki_page_alias_and_implication_list(wiki_page)
    antecedent_alias = wiki_page.presenter.antecedent_tag_alias
    consequent_aliases = wiki_page.presenter.consequent_tag_aliases
    antecedent_implications = wiki_page.presenter.antecedent_tag_implications
    consequent_implications = wiki_page.presenter.consequent_tag_implications

    html = ""

    if antecedent_alias
      html << "<p class='hint'>This tag has been aliased to "
      html << link_to(antecedent_alias.consequent_name, show_or_new_wiki_pages_path(:title => antecedent_alias.consequent_name))
      html << ".</p>"
    end

    if consequent_aliases.any?
      html << "<p class='hint'>The following tags are aliased to this tag: "
      html << raw(consequent_aliases.map {|x| link_to(x.antecedent_name, show_or_new_wiki_pages_path(:title => x.antecedent_name))}.join(", "))
      html << ".</p>"
    end

    if antecedent_implications.any?
      html << "<p class='hint'>This tag implicates "
      html << raw(antecedent_implications.map {|x| link_to(x.consequent_name, show_or_new_wiki_pages_path(:title => x.consequent_name))}.join(", "))
      html << ".</p>"
    end

    if consequent_implications.any?
      html << "<p class='hint'>The following tags implicate this tag: "
      html << raw(consequent_implications.map {|x| link_to(x.antecedent_name, show_or_new_wiki_pages_path(:title => x.antecedent_name))}.join(", "))
      html << ".</p>"
    end

    html.html_safe
  end
end
