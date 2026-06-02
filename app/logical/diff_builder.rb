# frozen_string_literal: true

require "diff/lcs/array" # diff-lcs gem

# Builds an HTML diff between two pieces of text.
class DiffBuilder
  BODY_PATTERN = %r{
    (?:<.+?>)               # HTML tags
    | (?:[\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]) # CJK / Hangul characters
    | (?:\w+)               # Latin words
    | (?:[ \t]+)            # Horizontal whitespace
    | (?:\r?\n)             # Line breaks
    | (?:.+?)               # Remaining individual characters
  }x

  attr_reader :this_text, :that_text, :pattern

  def self.diff_name_html(this_name, other_name)
    return "<ins>#{ERB::Util.html_escape(this_name)}</ins>".html_safe if other_name.blank?
    return "<del>#{ERB::Util.html_escape(other_name)}</del>".html_safe if this_name.blank?

    # Compute the longest common prefix and suffix so we only diff the changed middle.
    min_len = [this_name.length, other_name.length].min

    prefix_len = 0
    prefix_len += 1 while prefix_len < min_len && this_name[prefix_len] == other_name[prefix_len]

    suffix_len = 0
    while suffix_len < min_len - prefix_len &&
        this_name[this_name.length - 1 - suffix_len] == other_name[other_name.length - 1 - suffix_len]
      suffix_len += 1
    end

    prefix = this_name[0, prefix_len]
    suffix = this_name[-suffix_len, suffix_len]
    this_middle = this_name[prefix_len, this_name.length - prefix_len - suffix_len]
    other_middle = other_name[prefix_len, other_name.length - prefix_len - suffix_len]

    escaped_prefix = ERB::Util.html_escape(prefix)
    escaped_suffix = ERB::Util.html_escape(suffix)

    if levenshtein_similarity(this_middle, other_middle) < 0.3
      old_html = ERB::Util.html_escape(other_middle)
      new_html = ERB::Util.html_escape(this_middle)
      "#{escaped_prefix}<del>#{old_html}</del><ins>#{new_html}</ins>#{escaped_suffix}".html_safe
    else
      middle_html = new(this_middle, other_middle, /./).build
      "#{escaped_prefix}#{middle_html}#{escaped_suffix}".html_safe
    end
  end

  def self.diff_body_html(new_text, old_text)
    new_text = new_text.to_s
    old_text = old_text.to_s

    # Skip the expensive diff for long, completely different texts. The Levenshtein
    # check is O(n*m) in pure Ruby, so we only run it when both sides are small
    # enough that the shortcut is worth the cost.
    if new_text.length > 10 && [new_text.length, old_text.length].max <= 5_000 &&
        levenshtein_similarity(new_text, old_text) < 0.15
      old_html = format_body_html(old_text)
      new_html = format_body_html(new_text)
      "<del>#{old_html}</del><ins>#{new_html}</ins>".html_safe
    else
      new(new_text, old_text, BODY_PATTERN).build
    end
  end

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

    escape_html = ->(str) { str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;") }

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

      newchange = hunk.max { |a, b| a.old_position <=> b.old_position }
      newstart = newchange.old_position
      oldstart = hunk.min { |a, b| a.old_position <=> b.old_position }.old_position

      if newchange.action == "+"
        output.insert(newstart, "</ins>")
      end

      hunk.reverse_each do |chg|
        case chg.action
        when "-"
          oldstart = chg.old_position
          output[chg.old_position] = '<span class="paragraph-mark">¶</span><br>' if chg.old_element.match(/^\r?\n$/)
        when "+"
          if chg.new_element.match(/^\r?\n$/)
            output.insert(chg.old_position, '<span class="paragraph-mark">¶</span><br>')
          else
            output.insert(chg.old_position, escape_html[chg.new_element].to_s)
          end
        end
      end

      if newchange.action == "+"
        output.insert(newstart, "<ins>")
      end

      if hunk[0].action == "-"
        output.insert((newstart == oldstart || newchange.action != "+") ? newstart + 1 : newstart, "</del>")
        output.insert(oldstart, "<del>")
      end
    end

    output.join.gsub(/\r?\n/, '<span class="paragraph-mark">¶</span><br>').html_safe
  end

  def self.format_body_html(text)
    ERB::Util.html_escape(text).gsub(/\r?\n/, '<span class="paragraph-mark">¶</span><br>').html_safe
  end

  # Normalized Levenshtein similarity: 0.0 = completely different, 1.0 = identical.
  def self.levenshtein_similarity(a, b)
    max_len = [a.length, b.length].max
    return 1.0 if max_len.zero?

    1.0 - (DidYouMean::Levenshtein.distance(a, b).to_f / max_len)
  end
  private_class_method :levenshtein_similarity
end
