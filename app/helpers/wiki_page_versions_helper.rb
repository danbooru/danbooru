module WikiPageVersionsHelper
  def wiki_version_show_diff(wiki_page_version)
    previous = wiki_page_version.previous
    previous.present? && ((wiki_page_version.body != previous.body) || wiki_page_version.other_names_changed)
  end

  def wiki_version_show_other_names(new_version, old_version)
    ((new_version.other_names - old_version.other_names) | (old_version.other_names - new_version.other_names)).length > 0
  end

  def wiki_version_other_names_diff(new_version, old_version)
    new_names = new_version.other_names
    old_names = old_version.other_names
    latest_names = new_version.wiki_page.other_names

    diff_list_html(new_names, old_names, latest_names, ul_class: ["wiki-other-names-diff-list list-inline"], li_class: ["wiki-other-name"])
  end

  def wiki_version_title_diff(wiki_page_version)
    previous = wiki_page_version.previous
    if previous.present? && (wiki_page_version.title != previous.title)
      name_diff = diff_name_html(wiki_page_version.title, previous.title)
      %((<b>Rename:</b>&ensp;#{name_diff})).html_safe
    else
      ""
    end
  end
end
