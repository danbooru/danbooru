# frozen_string_literal: true

module TagNormalizer
  module_function

  # List of tag suffixes attached to tag other names
  # Ex: 西住みほ生誕祭2019 should be checked as 西住みほ
  # The regexes will not match if there is nothing preceding
  # the pattern to avoid creating empty strings.
  COMMON_TAG_REGEXES = [
    /(?<!\A)(生誕祭)(?:\d*)\z/,
    /(?<!\A)(誕生祭)(?:\d*)\z/,
    /(?<!\A)(版もうひとつの深夜の真剣お絵描き60分一本勝負)(?:_\d+)?\z/,
    /(?<!\A)(版深夜の真剣お絵描き60分一本勝負)(?:_\d+)?\z/,
    /(?<!\A)(版深夜の真剣お絵かき60分一本勝負)(?:_\d+)?\z/,
    /(?<!\A)(深夜の真剣お絵描き60分一本勝負)(?:_\d+)?\z/,
    /(?<!\A)(版深夜のお絵描き60分一本勝負)(?:_\d+)?\z/,
    /(?<!\A)(版真剣お絵描き60分一本勝)(?:_\d+)?\z/,
    /(?<!\A)(版お絵描き60分一本勝負)(?:_\d+)?\z/,
  ]

  # List of extra terms to strip from the tag.
  STRIP_TAG_REGEXES = [
    /\d+users入り\z/i,
  ]

  # Converts to tag into its canonical representation(s). Extractors may override this if
  # their site uses unusual conventions, such as Twitter's "one-hour drawing challenge" tags
  # counting as both "one-hour drawing challenge" and the respective copyright.
  #
  # @returns {Array<String>}
  def normalize(tag)
    tag = WikiPage.normalize_other_name(tag).downcase
    tag = tag.gsub(Regexp.union(STRIP_TAG_REGEXES), "")
    [
      tag,
      *tag.split(Regexp.union(COMMON_TAG_REGEXES)),
    ].sort.uniq
  end
end
