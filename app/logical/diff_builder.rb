# frozen_string_literal: true

require "diff/lcs/array" # diff-lcs gem
require "erb"
require "strscan"

# Builds escaped HTML diffs for version histories. Names have one grapheme-aligned
# replacement; bodies use word/tag/grapheme tokens to preserve separate edits.
#
# Body diffs trim common edges before checking the LCS budget. Within budget, one
# LCS pass supplies relevance matches and change hunks rendered from left to right.
# Over budget, identical content streams allow linear formatting alignment; otherwise
# replace the middle wholesale. Formatting-only edits never bypass the LCS budget.
class DiffBuilder
  WORD_TOKEN_PATTERN = /(?:\w\p{M}*)+/
  HORIZONTAL_WHITESPACE_PATTERN = /[ \t]+/
  GRAPHEME_PATTERN = /\X/
  CLOSING_ANGLE_PATTERN = />/
  TAG_TOKEN_PATTERN = /\A<.+?>\z/
  CONTENT_GRAPHEME_PATTERN = /[\p{L}\p{M}\p{N}\p{S}]/
  PARAGRAPH_MARK_HTML = '<span class="paragraph-mark">¶</span><br>'
  DIFFED_PARAGRAPH_MARK_HTML = '<del><span class="paragraph-mark">¶</span></del><ins><span class="paragraph-mark">¶</span></ins><br>'
  # Limits apply to the changed middle, not total input bytes or rendering time.
  MAX_LCS_MIDDLE_TOKENS = 20_000
  MAX_LCS_WORK = 1_000_000
  # A readability heuristic: a few incidental matches should not fragment a replacement.
  MIN_CONTENT_COVERAGE_PERCENT = 10

  private_constant :WORD_TOKEN_PATTERN, :HORIZONTAL_WHITESPACE_PATTERN, :GRAPHEME_PATTERN, :CLOSING_ANGLE_PATTERN,
                   :TAG_TOKEN_PATTERN, :CONTENT_GRAPHEME_PATTERN, :PARAGRAPH_MARK_HTML, :DIFFED_PARAGRAPH_MARK_HTML,
                   :MAX_LCS_MIDDLE_TOKENS, :MAX_LCS_WORK, :MIN_CONTENT_COVERAGE_PERCENT

  # Treat nil as empty text and discard SafeBuffer trust: even pre-marked-safe input must be escaped.
  def initialize(old_text:, new_text:)
    @old_text = String.new(old_text.to_s)
    @new_text = String.new(new_text.to_s)
  end

  # Render one replacement without splitting combining marks or emoji sequences. Do not normalize Unicode.
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

  # Keep LF and CRLF as distinct tokens so line-ending changes remain visible.
  def tokenize_body(text)
    text.each_line.flat_map do |line|
      newline = line[/\r?\n\z/]
      content = newline ? line.delete_suffix(newline) : line

      tokenize_body_line(content) + Array(newline)
    end
  end

  # Group words, horizontal whitespace, and nonempty <...> spans; otherwise take one grapheme.
  # Tag-shaped spans are lexical tokens, not parsed or trusted HTML.
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

  # Return the next '>' byte offset, advancing this independent scanner without backtracking.
  def next_closing_angle(scanner)
    return unless scanner.scan_until(CLOSING_ANGLE_PATTERN)

    scanner.pos - 1
  end

  # Return [prefix, old_middle, new_middle, suffix], with no overlap between the common edges.
  # Excluding these edges keeps large unchanged regions out of the budget and relevance checks.
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
    if old_tokens.empty? || new_tokens.empty?
      return render_token_change(old_tokens, new_tokens)
    end
    unless within_lcs_budget?(old_tokens, new_tokens)
      return render_formatting_change(old_tokens, new_tokens) || render_token_change(old_tokens, new_tokens)
    end

    hunks = Diff::LCS.diff(old_tokens, new_tokens, Diff::LCS::ContextDiffCallbacks.new)
    # With common edges removed, one hunk already replaces the entire middle.
    # Content analysis cannot improve that output, especially for long single tokens.
    if hunks.one? || unrelated_content?(old_tokens, new_tokens, hunks)
      return render_token_change(old_tokens, new_tokens)
    end

    render_diff(old_tokens, hunks)
  end

  # Repeated tokens create many matching pairs even in short inputs; length alone is not enough.
  def within_lcs_budget?(old_tokens, new_tokens)
    return false if old_tokens.length + new_tokens.length > MAX_LCS_MIDDLE_TOKENS

    # diff-lcs 2.0 visits equal-token pairs and searches an ordered threshold array.
    # Use n + m + matching_pairs * (1 + log_factor) as a conservative work estimate,
    # not a wall-clock or memory guarantee.
    new_frequencies = new_tokens.tally
    matching_pairs = old_tokens.tally.sum do |token, count|
      count * new_frequencies.fetch(token, 0)
    end
    log_factor = [old_tokens.length, new_tokens.length].min.bit_length
    estimated_work = old_tokens.length + new_tokens.length + (matching_pairs * (1 + log_factor))

    estimated_work <= MAX_LCS_WORK
  end

  # Reject low-coverage matches unless only formatting changed. Count letters, marks,
  # numbers, and symbols, not shared whitespace or markup that can make unrelated text look similar.
  def unrelated_content?(old_tokens, new_tokens, hunks)
    old_content = each_content_grapheme(old_tokens)
    new_content = each_content_grapheme(new_tokens)
    old_count = old_content.count
    new_count = new_content.count
    total_content = old_count + new_count
    return false if total_content.zero?

    deleted_content = hunks.sum do |hunk|
      each_content_grapheme(hunk.filter_map(&:old_element)).count
    end
    matched_content = old_count - deleted_content

    # Dice coverage is 2 * ordered matches / combined content length. Exactly 10% is retained.
    return false if (200 * matched_content) >= (MIN_CONTENT_COVERAGE_PERCENT * total_content)
    return true if old_count != new_count

    # A formatting edit can split/join words and leave few matching tokens. Equal-length,
    # identical content streams still deserve a detailed diff. Compare lazily to avoid
    # allocating a grapheme array for a long token, stopping at the first real difference.
    old_content.lazy.zip(new_content).any? do |old_grapheme, new_grapheme|
      old_grapheme != new_grapheme
    end
  end

  # Stream meaningful graphemes in order, omitting tag-shaped spans and punctuation (including '_').
  # Keeping this lazy avoids retaining a second array proportional to the body's character count.
  def each_content_grapheme(tokens)
    Enumerator.new do |graphemes|
      tokens.each do |token|
        next if token.match?(TAG_TOKEN_PATTERN)

        token.scan(GRAPHEME_PATTERN) do |grapheme|
          graphemes << grapheme if grapheme.match?(CONTENT_GRAPHEME_PATTERN)
        end
      end
    end
  end

  # Return nil on any content mismatch, never a partial diff. Only trim the edges of
  # formatting gaps; finding their internal LCS would defeat the linear fallback.
  def render_formatting_change(old_tokens, new_tokens)
    output = +""
    formatting_segments(old_tokens).zip(formatting_segments(new_tokens)) do |(old_format, old_content), (new_format, new_content)|
      return nil unless new_format && old_content == new_content

      if old_format == new_format
        output << render_plain_body(old_format)
      else
        prefix, old_middle, new_middle, suffix = trim_common_edges(old_format, new_format)
        output << render_plain_body(prefix) << render_token_change(old_middle, new_middle) << render_plain_body(suffix)
      end
      output << escape_text(old_content) if old_content
    end
    output
  end

  # Stream [preceding formatting, content grapheme] pairs. A final nil anchor keeps
  # trailing formatting and ensures zip cannot silently truncate unequal content streams.
  def formatting_segments(tokens)
    Enumerator.new do |segments|
      formatting = []
      tokens.each do |token|
        if token.match?(TAG_TOKEN_PATTERN) || !token.match?(CONTENT_GRAPHEME_PATTERN)
          formatting << token
          next
        end

        token.scan(GRAPHEME_PATTERN) do |grapheme|
          if grapheme.match?(CONTENT_GRAPHEME_PATTERN)
            segments << [formatting, grapheme]
            formatting = []
          else
            formatting << grapheme
          end
        end
      end
      segments << [formatting, nil]
    end
  end

  # Render ContextDiffCallbacks' ordered +/- hunks, separated by unchanged old tokens.
  # Each hunk starts at its first old_position and consumes only its deleted tokens;
  # insertions never advance the old cursor. Complete tags avoid shifting indexes or nesting changes.
  def render_diff(old_tokens, hunks)
    old_cursor = 0
    parts = hunks.flat_map do |hunk|
      deleted_tokens = hunk.filter_map(&:old_element)
      inserted_tokens = hunk.filter_map(&:new_element)
      hunk_start = hunk.first.old_position
      unchanged_tokens = old_tokens[old_cursor...hunk_start]
      old_cursor = hunk_start + deleted_tokens.length

      [render_plain_body(unchanged_tokens), render_token_change(deleted_tokens, inserted_tokens)]
    end

    parts.push(render_plain_body(old_tokens[old_cursor..])).join
  end

  def newline?(text)
    ["\n", "\r\n"].include?(text)
  end

  def render_token_change(old_tokens, new_tokens)
    # An LF/CRLF replacement has one visible break, not two displayed paragraphs.
    if old_tokens.one? && new_tokens.one? && newline?(old_tokens.first) && newline?(new_tokens.first)
      return DIFFED_PARAGRAPH_MARK_HTML
    end

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

  # Return escaped text as a plain String so intermediate concatenation cannot skip escaping.
  def escape_text(text)
    String.new(ERB::Util.html_escape(text))
  end

  # Mark only the final assembly safe; all source text must have passed through escape_text.
  def safe_html(output)
    output.html_safe # rubocop:disable Rails/OutputSafety
  end
end
