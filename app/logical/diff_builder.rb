# frozen_string_literal: true

# Builds an HTML diff between two pieces of text.
class DiffBuilder
  attr_reader :this_text, :that_text, :pattern

  def initialize(this_text, that_text, pattern)
    @this_text = this_text
    @that_text = that_text
    @pattern = pattern
  end

  def build
    thisarr = this_text.scan(pattern)
    otharr = that_text.scan(pattern)

    cbo = Diff::LCS::ContextDiffCallbacks.new
    diffs = otharr.diff(thisarr, cbo)

    escape_html = ->(str) {str.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;')}

    output = otharr
    output.each { |q| q.replace(escape_html[q]) }

    diffs.reverse_each do |hunk|
      old_cr = hunk[0].try(:old_element)
      new_cr = hunk[1].try(:new_element)
      if old_cr && new_cr && old_cr.match?(/^\r?\n$/) && new_cr.match?(/^\r?\n$/)
        hunk_position = hunk[0].old_position
        output[hunk_position] = '<del><span class="paragraph-mark">¶</span></del><ins><span class="paragraph-mark">¶</span></ins><br>'
        next
      end

      newchange = hunk.max {|a, b| a.old_position <=> b.old_position}
      newstart = newchange.old_position
      oldstart = hunk.min {|a, b| a.old_position <=> b.old_position}.old_position

      if newchange.action == '+'
        output.insert(newstart, '</ins>')
      end

      hunk.reverse_each do |chg|
        case chg.action
        when '-'
          oldstart = chg.old_position
          output[chg.old_position] = '<span class="paragraph-mark">¶</span><br>' if chg.old_element.match(/^\r?\n$/)
        when '+'
          if chg.new_element.match(/^\r?\n$/)
            output.insert(chg.old_position, '<span class="paragraph-mark">¶</span><br>')
          else
            output.insert(chg.old_position, (escape_html[chg.new_element]).to_s)
          end
        end
      end

      if newchange.action == '+'
        output.insert(newstart, '<ins>')
      end

      if hunk[0].action == '-'
        output.insert((newstart == oldstart || newchange.action != '+') ? newstart + 1 : newstart, '</del>')
        output.insert(oldstart, '<del>')
      end
    end

    output.join.gsub(/\r?\n/, '<span class="paragraph-mark">¶</span><br>').html_safe
  end
end
