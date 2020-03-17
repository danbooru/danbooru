module WikiPageVersionsHelper
  def wiki_version_show_diff(wiki_page_version, type)
    other = wiki_page_version.send(type)
    other.present? && ((wiki_page_version.body != other.body) || wiki_page_version.other_names_changed(type))
  end

  def wiki_version_show_other_names(this_version, other_version)
    ((this_version.other_names - other_version.other_names) | (other_version.other_names - this_version.other_names)).length.positive?
  end

  def wiki_version_other_names_diff(this_version, other_version)
    this_names = this_version.other_names
    other_names = other_version.other_names

    diff_list_html(this_names, other_names, ul_class: ["wiki-other-names-diff-list list-inline"], li_class: ["wiki-other-name"])
  end

  def wiki_version_title_diff(wiki_page_version, type)
    other = wiki_page_version.send(type)
    if other.present? && (wiki_page_version.title != other.title)
      if type == "previous"
        name_diff = diff_name_html(wiki_page_version.title, other.title)
      else
        name_diff = diff_name_html(other.title, wiki_page_version.title)
      end
      %((<b>Rename:</b>&ensp;#{name_diff})).html_safe
    else
      ""
    end
  end
end
