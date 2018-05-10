module WikiPageVersionsHelper
  def wiki_page_diff(thispage, otherpage)
    pattern = Regexp.new('(?:<.+?>)|(?:\w+)|(?:[ \t]+)|(?:\r?\n)|(?:.+?)')
    other_names_pattern = Regexp.new('\S+|\s+')

    thisarr = thispage.body.scan(pattern)
    otharr = otherpage.body.scan(pattern)

    if thispage.other_names.present? || otherpage.other_names.present?
      thisarr = "#{thispage.other_names}\n\n".scan(other_names_pattern) + thisarr
      otharr = "#{otherpage.other_names}\n\n".scan(other_names_pattern) + otharr
    end

    cbo = Diff::LCS::ContextDiffCallbacks.new
    diffs = thisarr.diff(otharr, cbo)

    escape_html = ->(str) {str.gsub(/&/,'&amp;').gsub(/</,'&lt;').gsub(/>/,'&gt;')}

    output = thisarr
    output.each { |q| q.replace(escape_html[q]) }

    diffs.reverse_each do |hunk|
      newchange = hunk.max{|a,b| a.old_position <=> b.old_position}
      newstart = newchange.old_position
      oldstart = hunk.min{|a,b| a.old_position <=> b.old_position}.old_position

      if newchange.action == '+'
        output.insert(newstart, '</ins>')
      end

      hunk.reverse_each do |chg|
        case chg.action
        when '-'
          oldstart = chg.old_position
          output[chg.old_position] = '<br>' if chg.old_element.match(/^\r?\n$/)
        when '+'
          if chg.new_element.match(/^\r?\n$/)
            output.insert(chg.old_position, '<br>')
          else
            output.insert(chg.old_position, "#{escape_html[chg.new_element]}")
          end
        end
      end

      if newchange.action == '+'
        output.insert(newstart, '<ins>')
      end

      if hunk[0].action == '-'
        output.insert((newstart == oldstart || newchange.action != '+') ? newstart+1 : newstart, '</del>')
        output.insert(oldstart, '<del>')
      end
    end

    output.join.gsub(/\r?\n/, '<br>').html_safe
  end
end
