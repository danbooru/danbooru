# frozen_string_literal: true

require "diff/lcs/array" # diff-lcs gem

# Builds an HTML diff between two pieces of text.
class DiffBuilder
  NAME_PATTERN = /./
  BODY_PATTERN = %r{
    (?:<.+?>)               # HTML tags
    | (?:[\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]) # CJK / Hangul characters
    | (?:\w+)               # Latin words
    | (?:[ \t]+)            # Horizontal whitespace
    | (?:\r?\n)             # Line breaks
    | (?:.+?)               # Remaining individual characters
  }x
  PARAGRAPH_MARK_HTML = '<span class="paragraph-mark">¶</span><br>'
  DIFFED_PARAGRAPH_MARK_HTML = '<del><span class="paragraph-mark">¶</span></del><ins><span class="paragraph-mark">¶</span></ins><br>'
  MAX_LEVENSHTEIN_LENGTH = 5_000
  MIN_WHOLESALE_DIFF_LENGTH = 10
  WHOLESALE_BODY_DIFF_SIMILARITY = 0.15

  attr_reader :this_text, :that_text, :pattern

  def initialize(this_text, that_text, pattern = BODY_PATTERN)
    @this_text = this_text.to_s
    @that_text = that_text.to_s
    @pattern = pattern
  end

  def diff_name_html
    return diff_html(new_text: this_text) if that_text.blank?
    return diff_html(old_text: that_text) if this_text.blank?

    # Compute the longest common prefix and suffix so we only diff the changed middle.
    min_len = [this_text.length, that_text.length].min

    prefix_len = 0
    prefix_len += 1 while prefix_len < min_len && this_text[prefix_len] == that_text[prefix_len]

    suffix_len = 0
    while suffix_len < min_len - prefix_len &&
        this_text[this_text.length - 1 - suffix_len] == that_text[that_text.length - 1 - suffix_len]
      suffix_len += 1
    end

    prefix = this_text[0, prefix_len]
    suffix = this_text[-suffix_len, suffix_len]
    this_middle = this_text[prefix_len, this_text.length - prefix_len - suffix_len]
    other_middle = that_text[prefix_len, that_text.length - prefix_len - suffix_len]

    if levenshtein_similarity(this_middle, other_middle) < 0.3
      diff_html(prefix: prefix, old_text: other_middle, new_text: this_middle, suffix: suffix)
    else
      middle_html = self.class.new(this_middle, other_middle, pattern).build
      diff_html(prefix: prefix, middle_html: middle_html, suffix: suffix)
    end
  end

  def diff_body_html
    # Avoid an O(n*m) Levenshtein check on long bodies.
    max_length = [this_text.length, that_text.length].max

    if max_length > MIN_WHOLESALE_DIFF_LENGTH &&
        max_length <= MAX_LEVENSHTEIN_LENGTH &&
        levenshtein_similarity(this_text, that_text) < WHOLESALE_BODY_DIFF_SIMILARITY
      diff_html(old_text: that_text, new_text: this_text, paragraph_marks: true)
    else
      build
    end
  end

  # Renders one side of a version diff without change markers. Used when the
  # other side is missing, so there is nothing to compare against.
  def format_body_html
    format_diff_text(this_text, paragraph_marks: true).html_safe
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
        output[hunk_position] = DIFFED_PARAGRAPH_MARK_HTML
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
          output[chg.old_position] = PARAGRAPH_MARK_HTML if chg.old_element.match(/^\r?\n$/)
        when "+"
          if chg.new_element.match(/^\r?\n$/)
            output.insert(chg.old_position, PARAGRAPH_MARK_HTML)
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

    output.join.gsub(/\r?\n/, PARAGRAPH_MARK_HTML).html_safe
  end

  private

  def diff_html(prefix: nil, old_text: nil, new_text: nil, middle_html: nil, suffix: nil, paragraph_marks: false)
    html = +""

    html << format_diff_text(prefix) unless prefix.nil?

    if middle_html.nil?
      unless old_text.nil? || old_text.empty?
        html << "<del>#{format_diff_text(old_text, paragraph_marks: paragraph_marks)}</del>"
      end

      unless new_text.nil? || new_text.empty?
        html << "<ins>#{format_diff_text(new_text, paragraph_marks: paragraph_marks)}</ins>"
      end
    else
      html << middle_html
    end

    html << format_diff_text(suffix) unless suffix.nil?

    html.html_safe
  end

  def format_diff_text(text, paragraph_marks: false)
    html = ERB::Util.html_escape(text)
    html = html.gsub(/\r?\n/, PARAGRAPH_MARK_HTML) if paragraph_marks
    html
  end

  # Normalized Levenshtein similarity: 0.0 = completely different, 1.0 = identical.
  def levenshtein_similarity(a, b)
    max_len = [a.length, b.length].max
    return 1.0 if max_len.zero?

    1.0 - (DidYouMean::Levenshtein.distance(a, b).to_f / max_len)
  end
end
