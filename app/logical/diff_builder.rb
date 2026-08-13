# frozen_string_literal: true

require "diff/lcs/array" # diff-lcs gem
require "erb"
require "strscan"

# Builds an HTML diff between two pieces of text.
class DiffBuilder
  WORD_TOKEN_PATTERN = /(?:\w\p{M}*)+/
  HORIZONTAL_WHITESPACE_PATTERN = /[ \t]+/
  GRAPHEME_PATTERN = /\X/
  CLOSING_ANGLE_PATTERN = />/
  TAG_TOKEN_PATTERN = /\A<.+?>\z/
  CONTENT_GRAPHEME_PATTERN = /[\p{L}\p{M}\p{N}\p{S}]/
  PARAGRAPH_MARK_HTML = '<span class="paragraph-mark">¶</span><br>'
  DIFFED_PARAGRAPH_MARK_HTML = '<del><span class="paragraph-mark">¶</span></del><ins><span class="paragraph-mark">¶</span></ins><br>'
  MAX_LCS_MIDDLE_TOKENS = 20_000
  MAX_LCS_WORK = 1_000_000
  MIN_CONTENT_COVERAGE_PERCENT = 10

  private_constant :WORD_TOKEN_PATTERN, :HORIZONTAL_WHITESPACE_PATTERN, :GRAPHEME_PATTERN, :CLOSING_ANGLE_PATTERN,
                   :TAG_TOKEN_PATTERN, :CONTENT_GRAPHEME_PATTERN, :PARAGRAPH_MARK_HTML, :DIFFED_PARAGRAPH_MARK_HTML,
                   :MAX_LCS_MIDDLE_TOKENS, :MAX_LCS_WORK, :MIN_CONTENT_COVERAGE_PERCENT

  def initialize(old_text:, new_text:)
    @old_text = untrusted_string(old_text)
    @new_text = untrusted_string(new_text)
  end

  def name_html
    old_graphemes = old_text.scan(GRAPHEME_PATTERN)
    new_graphemes = new_text.scan(GRAPHEME_PATTERN)
    prefix, old_middle, new_middle, suffix = trim_common_edges(old_graphemes, new_graphemes)

    safe_html([
      escape_text(prefix.join),
      render_tagged_text("del", old_middle.join),
      render_tagged_text("ins", new_middle.join),
      escape_text(suffix.join),
    ].join)
  end

  def body_html
    old_tokens = tokenize_body(old_text)
    new_tokens = tokenize_body(new_text)
    prefix, old_middle, new_middle, suffix = trim_common_edges(old_tokens, new_tokens)

    safe_html([
      render_plain_body(prefix),
      render_body_change(old_middle, new_middle),
      render_plain_body(suffix),
    ].join)
  end

  private

  attr_reader :old_text, :new_text

  def untrusted_string(text)
    String.new(text.to_s)
  end

  def tokenize_body(text)
    text.each_line.flat_map do |line|
      newline = line[/\r?\n\z/]
      content = newline ? line.delete_suffix(newline) : line

      tokenize_body_line(content) + Array(newline)
    end
  end

  def tokenize_body_line(line)
    scanner = StringScanner.new(line)
    # Keep closing-tag searches monotonic so malformed "<" runs stay linear.
    closing_scanner = StringScanner.new(line)
    closing_position = next_closing_angle(closing_scanner)
    tokens = []

    until scanner.eos?
      if scanner.peek(1) == "<"
        minimum_closing_position = scanner.pos + 2
        closing_position = next_closing_angle(closing_scanner) while closing_position && closing_position < minimum_closing_position

        if closing_position
          tokens << line.byteslice(scanner.pos, closing_position - scanner.pos + 1)
          scanner.pos = closing_position + 1
          next
        end
      end

      tokens << (scanner.scan(WORD_TOKEN_PATTERN) || scanner.scan(HORIZONTAL_WHITESPACE_PATTERN) || scanner.scan(GRAPHEME_PATTERN))
    end

    tokens
  end

  def next_closing_angle(scanner)
    return unless scanner.scan_until(CLOSING_ANGLE_PATTERN)

    scanner.pos - 1
  end

  def trim_common_edges(old_units, new_units)
    limit = [old_units.length, new_units.length].min
    prefix_length = limit.times.find { |index| old_units[index] != new_units[index] } || limit
    suffix_limit = limit - prefix_length
    suffix_length = suffix_limit.times.find do |offset|
      old_units[-offset - 1] != new_units[-offset - 1]
    end || suffix_limit

    old_middle_length = old_units.length - prefix_length - suffix_length
    new_middle_length = new_units.length - prefix_length - suffix_length

    [
      old_units.first(prefix_length),
      old_units[prefix_length, old_middle_length],
      new_units[prefix_length, new_middle_length],
      old_units.last(suffix_length),
    ]
  end

  def render_body_change(old_tokens, new_tokens)
    return render_token_change(old_tokens, new_tokens) if old_tokens.empty? || new_tokens.empty?

    old_content_count, new_content_count, content_changed = compare_content(old_tokens, new_tokens)
    unless within_lcs_budget?(old_tokens, new_tokens)
      return render_format_only_diff(old_tokens, new_tokens) unless content_changed

      return render_token_change(old_tokens, new_tokens)
    end

    hunks = Diff::LCS.diff(old_tokens, new_tokens, Diff::LCS::ContextDiffCallbacks.new)
    low_coverage = content_changed && low_content_coverage?(old_content_count, new_content_count, hunks)
    return render_token_change(old_tokens, new_tokens) if low_coverage

    render_legacy_diff(old_tokens, hunks)
  end

  def within_lcs_budget?(old_tokens, new_tokens)
    return false if old_tokens.length + new_tokens.length > MAX_LCS_MIDDLE_TOKENS

    # diff-lcs work scales with the number of equal-token pairs.
    new_frequencies = new_tokens.tally
    matching_pairs = old_tokens.tally.sum do |token, count|
      count * new_frequencies.fetch(token, 0)
    end
    log_factor = [old_tokens.length, new_tokens.length].min.bit_length
    estimated_work = old_tokens.length + new_tokens.length + (matching_pairs * (1 + log_factor))

    estimated_work <= MAX_LCS_WORK
  end

  def low_content_coverage?(old_content_count, new_content_count, hunks)
    total_content = old_content_count + new_content_count
    return false if total_content.zero?

    deleted_content = hunks.sum do |hunk|
      hunk.sum { |change| (change.action == "-") ? content_weight(change.old_element) : 0 }
    end
    matched_content = old_content_count - deleted_content

    # Dice coverage is twice the matched content divided by both content lengths.
    (200 * matched_content) < (MIN_CONTENT_COVERAGE_PERCENT * total_content)
  end

  def compare_content(old_tokens, new_tokens)
    old_content = each_content_grapheme(old_tokens)
    new_content = each_content_grapheme(new_tokens)
    end_marker = Object.new
    old_count = 0
    new_count = 0
    content_changed = false

    loop do
      old_grapheme = next_content_grapheme(old_content, end_marker)
      new_grapheme = next_content_grapheme(new_content, end_marker)
      old_finished = old_grapheme.equal?(end_marker)
      new_finished = new_grapheme.equal?(end_marker)
      break if old_finished && new_finished

      old_count += 1 unless old_finished
      new_count += 1 unless new_finished
      content_changed = true unless old_grapheme == new_grapheme
    end

    [old_count, new_count, content_changed]
  end

  def each_content_grapheme(tokens)
    # Yield graphemes instead of retaining an array for long single-token bodies.
    Enumerator.new do |graphemes|
      tokens.each do |token|
        next if token.match?(TAG_TOKEN_PATTERN)

        token.scan(GRAPHEME_PATTERN) do |grapheme|
          graphemes << grapheme if grapheme.match?(CONTENT_GRAPHEME_PATTERN)
        end
      end
    end
  end

  def next_content_grapheme(graphemes, end_marker)
    graphemes.next
  rescue StopIteration
    end_marker
  end

  def content_weight(token)
    return 0 if token.match?(TAG_TOKEN_PATTERN)

    token.to_enum(:scan, GRAPHEME_PATTERN).count { |grapheme| grapheme.match?(CONTENT_GRAPHEME_PATTERN) }
  end

  def render_format_only_diff(old_tokens, new_tokens)
    old_atoms = each_body_atom(old_tokens)
    new_atoms = each_body_atom(new_tokens)
    end_marker = Object.new
    output = +""

    loop do
      old_format, old_content = next_content_segment(old_atoms, end_marker)
      new_format, new_content = next_content_segment(new_atoms, end_marker)
      output << render_format_change(old_format, new_format)
      return output if old_content.equal?(end_marker) && new_content.equal?(end_marker)

      output << escape_text(old_content)
    end
  end

  def each_body_atom(tokens)
    Enumerator.new do |atoms|
      tokens.each do |token|
        if token.match?(TAG_TOKEN_PATTERN) || !token.match?(CONTENT_GRAPHEME_PATTERN)
          atoms << [:format, token]
          next
        end

        token.scan(GRAPHEME_PATTERN) do |grapheme|
          kind = grapheme.match?(CONTENT_GRAPHEME_PATTERN) ? :content : :format
          atoms << [kind, grapheme]
        end
      end
    end
  end

  def next_content_segment(atoms, end_marker)
    format = []
    kind, value = atoms.next

    until kind == :content
      format << value
      kind, value = atoms.next
    end

    [format, value]
  rescue StopIteration
    [format, end_marker]
  end

  def render_format_change(old_format, new_format)
    prefix, old_middle, new_middle, suffix = trim_common_edges(old_format, new_format)
    newline_change = old_middle.one? && new_middle.one? && newline?(old_middle[0]) && newline?(new_middle[0])
    change = newline_change ? DIFFED_PARAGRAPH_MARK_HTML : render_token_change(old_middle, new_middle)

    render_plain_body(prefix) + change + render_plain_body(suffix)
  end

  def render_legacy_diff(old_tokens, hunks)
    output = old_tokens.map { |token| escape_text(token) }

    hunks.reverse_each do |hunk|
      apply_legacy_hunk(output, hunk)
    end

    format_paragraphs(output.join)
  end

  def apply_legacy_hunk(output, hunk)
    if newline_replacement?(hunk)
      output[hunk[0].old_position] = DIFFED_PARAGRAPH_MARK_HTML
      return
    end

    new_change = hunk.max_by(&:old_position)
    new_start = new_change.old_position
    old_start = hunk.min_by(&:old_position).old_position
    has_insertion = new_change.action == "+"
    output.insert(new_start, "</ins>") if has_insertion

    hunk.reverse_each do |change|
      old_start = apply_legacy_change(output, change, old_start)
    end

    output.insert(new_start, "<ins>") if has_insertion
    return unless hunk[0].action == "-"

    closing_position = (new_start == old_start || !has_insertion) ? new_start + 1 : new_start
    output.insert(closing_position, "</del>")
    output.insert(old_start, "<del>")
  end

  def apply_legacy_change(output, change, old_start)
    if change.action == "-"
      output[change.old_position] = PARAGRAPH_MARK_HTML if newline?(change.old_element)
      change.old_position
    elsif newline?(change.new_element)
      output.insert(change.old_position, PARAGRAPH_MARK_HTML)
      old_start
    else
      output.insert(change.old_position, escape_text(change.new_element))
      old_start
    end
  end

  def newline_replacement?(hunk)
    old_element = hunk[0]&.old_element
    new_element = hunk[1]&.new_element

    old_element && new_element && newline?(old_element) && newline?(new_element)
  end

  def newline?(text)
    ["\n", "\r\n"].include?(text)
  end

  def render_token_change(old_tokens, new_tokens)
    render_tagged_body("del", old_tokens) + render_tagged_body("ins", new_tokens)
  end

  def render_tagged_body(tag_name, tokens)
    return "" if tokens.empty?

    "<#{tag_name}>#{render_plain_body(tokens)}</#{tag_name}>"
  end

  def render_plain_body(tokens)
    format_paragraphs(escape_text(tokens.join))
  end

  def render_tagged_text(tag_name, value)
    return "" if value.empty?

    "<#{tag_name}>#{escape_text(value)}</#{tag_name}>"
  end

  def format_paragraphs(text)
    text.gsub(/\r?\n/, PARAGRAPH_MARK_HTML)
  end

  def escape_text(text)
    String.new(ERB::Util.html_escape(text))
  end

  def safe_html(output)
    output.html_safe # rubocop:disable Rails/OutputSafety
  end
end
