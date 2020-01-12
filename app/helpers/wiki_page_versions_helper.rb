module WikiPageVersionsHelper
  def wiki_page_version_status_diff(wiki_page_version)
    cur = wiki_page_version
    prev = wiki_page_version.previous

    return "New" if prev.blank?

    status = []
    status += ["Renamed"] if cur.title != prev.title
    status += ["Deleted"] if cur.is_deleted? && !prev.is_deleted?
    status += ["Undeleted"] if !cur.is_deleted? && prev.is_deleted?
    status.join(" ")
  end

  def wiki_other_names_diff(new_version, old_version)
    new_names = new_version.other_names
    old_names = old_version.other_names
    latest_names = new_version.wiki_page.other_names

    diff_list_html(new_names, old_names, latest_names, ul_class: ["wiki-other-names-diff-list list-inline"], li_class: ["wiki-other-name"])
  end

  def wiki_body_diff(thispage, otherpage)
    pattern = Regexp.new('(?:<.+?>)|(?:\w+)|(?:[ \t]+)|(?:\r?\n)|(?:.+?)')
    DiffBuilder.new(thispage.body, otherpage.body, pattern).build
  end
end
