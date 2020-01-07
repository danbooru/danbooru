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

  def wiki_other_names_diff(thispage, otherpage)
    pattern = Regexp.new('\S+|\s+')
    DiffBuilder.new("#{thispage.other_names}\n\n", "#{otherpage.other_names}\n\n", pattern).build
  end

  def wiki_body_diff(thispage, otherpage)
    pattern = Regexp.new('(?:<.+?>)|(?:\w+)|(?:[ \t]+)|(?:\r?\n)|(?:.+?)')
    DiffBuilder.new(thispage.body, otherpage.body, pattern).build
  end
end
