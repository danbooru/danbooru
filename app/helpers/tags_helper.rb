module TagsHelper
  def alias_and_implication_list(tag)
    return "" if tag.nil?

    html = ""

    if tag.antecedent_alias
      html << "<p class='fineprint'>This tag has been aliased to "
      html << link_to_wiki(tag.antecedent_alias.consequent_name)
      html << " (#{link_to_wiki "learn more", "help:tag_aliases"}).</p>"
    end

    if tag.consequent_aliases.present?
      html << "<p class='fineprint'>The following tags are aliased to this tag: "
      html << raw(tag.consequent_aliases.map {|x| link_to_wiki x.antecedent_name }.join(", "))
      html << " (#{link_to_wiki "learn more", "help:tag_aliases"}).</p>"
    end

    automatic_tags = TagImplication.automatic_tags_for([tag.name])
    if automatic_tags.present?
      html << "<p class='fineprint'>This tag automatically adds "
      html << raw(automatic_tags.map {|x| link_to_wiki x, x }.join(", "))
      html << " (#{link_to_wiki "learn more", "help:autotags"}).</p>"
    end

    if tag.antecedent_implications.present?
      html << "<p class='fineprint'>This tag implicates "
      html << raw(tag.antecedent_implications.map {|x| link_to_wiki x.consequent_name }.join(", "))
      html << " (#{link_to_wiki "learn more", "help:tag_implications"}).</p>"
    end

    if tag.consequent_implications.present?
      html << "<p class='fineprint'>The following tags implicate this tag: "
      html << raw(tag.consequent_implications.map {|x| link_to_wiki x.antecedent_name }.join(", "))
      html << " (#{link_to_wiki "learn more", "help:tag_implications"}).</p>"
    end

    html.html_safe
  end
end
