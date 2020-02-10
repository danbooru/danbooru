module WikiPageVersionsHelper
  def wiki_other_names_diff(new_version, old_version)
    new_names = new_version.other_names
    old_names = old_version.other_names
    latest_names = new_version.wiki_page.other_names

    diff_list_html(new_names, old_names, latest_names, ul_class: ["wiki-other-names-diff-list list-inline"], li_class: ["wiki-other-name"])
  end
end
