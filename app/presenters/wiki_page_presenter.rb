class WikiPagePresenter
  attr_reader :wiki_page

  def initialize(wiki_page)
    @wiki_page = wiki_page
  end

  def excerpt
    wiki_page.body
  end

  def blurb
    DText.strip(excerpt.to_s)
  end

  # Produce a formatted page that shows the difference between two versions of a page.
  def diff(other_version)
    pattern = Regexp.new('(?:<.+?>)|(?:[0-9_A-Za-z\x80-\xff]+[\x09\x20]?)|(?:[ \t]+)|(?:\r?\n)|(?:.+?)')

    thisarr = self.body.scan(pattern)
    otharr = other_version.body.scan(pattern)

    cbo = Diff::LCS::ContextDiffCallbacks.new
    diffs = thisarr.diff(otharr, cbo)

    escape_html = lambda {|str| str.gsub(/&/,'&amp;').gsub(/</,'&lt;').gsub(/>/,'&gt;')}

    output = thisarr;
    output.each { |q| q.replace(CGI.escape_html(q)) }

    diffs.reverse_each do |hunk|
      newchange = hunk.max{|a,b| a.old_position <=> b.old_position}
      newstart = newchange.old_position
      oldstart = hunk.min{|a,b| a.old_position <=> b.old_position}.old_position

      if newchange.action == '+'
        output.insert(newstart, "</ins>")
      end

      hunk.reverse_each do |chg|
        case chg.action
        when '-'
          oldstart = chg.old_position
          output[chg.old_position] = "" if chg.old_element.match(/^\r?\n$/)
        when '+'
          if chg.new_element.match(/^\r?\n$/)
            output.insert(chg.old_position, "[nl]")
          else
            output.insert(chg.old_position, "#{escape_html[chg.new_element]}")
          end
        end
      end

      if newchange.action == '+'
        output.insert(newstart, "<ins>")
      end

      if hunk[0].action == '-'
        output.insert((newstart == oldstart || newchange.action != '+') ? newstart+1 : newstart, "</del>")
        output.insert(oldstart, "<del>")
      end
    end

    output.join.gsub(/\r?\n/, "[nl]")
  end
end
