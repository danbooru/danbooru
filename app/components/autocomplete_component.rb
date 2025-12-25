# frozen_string_literal: true

class AutocompleteComponent < ApplicationComponent
  attr_reader :autocomplete_service

  delegate :humanized_number, to: :helpers
  delegate :autocomplete_results, :query, :metatag, to: :autocomplete_service

  def initialize(autocomplete_service:)
    @autocomplete_service = autocomplete_service
  end

  def link_to_result(result, &block)
    case result.type
    when "user", "mention"
      link_to user_path(result.id), class: "user-#{result.level} flex-grow-1", "@click.prevent": "", &block
    when "pool"
      link_to pool_path(result.id), class: "pool-category-#{result.category} flex-grow-1", "@click.prevent": "", &block
    when "emoji"
      link_to "javascript:void(0)", class: "tag-type-#{Tag.categories.general} flex-grow-1", "@click.prevent": "", &block
    else
      link_to posts_path(tags: result.value), class: "tag-type-#{result.category} flex-grow-1", "@click.prevent": "", &block
    end
  end

  def highlight_antecedent(result)
    if result.type == "tag-word"
      highlight_matching_words(result.antecedent, query)
    elsif query.include?("*")
      highlight_wildcard_match(result.antecedent, query)
    else
      highlight_wildcard_match(result.antecedent, query + "*")
    end
  end

  def highlight_result(result)
    if metatag.present? && metatag.value.include?("*")
      highlight_wildcard_match(result.label, metatag.value)
    elsif metatag.present? && metatag.name.in?(%w[pool favgroup])
      highlight_wildcard_match(result.label, "*" + metatag.value + "*")
    elsif metatag.present? && metatag.name.in?(%w[ai unaliased])
      highlight_matching_words(result.label, metatag.value)
    elsif metatag.present?
      highlight_wildcard_match(result.label, metatag.value + "*")
    elsif result.type == "tag-word"
      highlight_matching_words(result.value, query)
    elsif result.type == "mention"
      highlight_wildcard_match(result.label, query + "*")
    elsif result.type == "emoji"
      highlight_wildcard_match(result.label, "*" + query + "*")
    elsif query.include?("*")
      highlight_wildcard_match(result.value, query)
    else
      highlight_wildcard_match(result.value, query + "*")
    end
  end

  # Highlight the words in the `target` string matching the words in the search `pattern`.
  #
  # highlight_matching_words("very_long_hair", "long_ha*") => "<span>very_</span><b>long</b><span>_</span><b>hair</b>"
  def highlight_matching_words(target, pattern)
    pattern_words = Tag.parse_query(pattern)
    pattern_words.sort_by! { |word| [word.include?("*") ? 1 : 0, -word.size] }

    target_words = Tag.split_words(target)
    target_words.map do |word|
      pat = pattern_words.find { |pat| word.ilike?(pat) }
      highlight_wildcard_match(word, pat)
    end.join("").html_safe
  end

  # Highlight the parts of the `target` string that match the wildcard search `pattern`.
  #
  # highlight_wildcard_match("very_long_hair", "*long*") => "<span>very_</span><b>long</b><span>_hair</span>"
  def highlight_wildcard_match(target, pattern)
    return tag.span(target.tr("_", " ")) if !target.ilike?(pattern.to_s)

    words = pattern.split(/(\*)/).compact_blank # "*black*" => ["*", "black", "*"]
    regexp = words.map { |w| (w == "*") ? "(.*)" : "(#{Regexp.escape(w.gsub("\\\\", "\\"))})" }.join # "*black*" => "(.*)(black)(.*)"
    regexp = Regexp.new(regexp, "i")
    captures = target.match(regexp).captures # "black_thighhighs" =~ /(.*)(black)(.*)/ => ["", "black", "_thighhighs"]

    captures.zip(words).map do |substring, word|
      if substring == ""
        ""
      elsif word == "*"
        tag.span(substring.tr("_", " "))
      else
        tag.b(substring.tr("_", " "))
      end
    end.join.html_safe
  end
end
