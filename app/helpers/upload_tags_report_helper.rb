module UploadTagsReportHelper
  def diff_to_current(report)
    html = '<span class="diff-list">'

    report.added_tags_array.each do |tag|
      html << '<ins>+' + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</ins>'
    end
    report.removed_tags_array.each do |tag|
      html << '<del>-' + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</del>'
    end

    html << "</span>"
    html.html_safe
  end
end
