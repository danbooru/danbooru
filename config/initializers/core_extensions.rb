# frozen_string_literal: true

require "danbooru"
require_relative "../../app/logical/danbooru/enumerable"

module Danbooru
  module Extensions
    module String
      # https://invisible-characters.com
      # https://character.construction/blanks
      # https://www.unicode.org/review/pr-5.html (5.22 Default Ignorable Code Points)
      # https://en.wikipedia.org/wiki/Whitespace_character
      #
      # [[:space:]] = https://codepoints.net/search?gc[]=Z (Space_Separator | Line_Separator | Paragraph_Separator | U+0009 | U+000A | U+000B | U+000C | U+000D | U+0085)
      # \p{di} = https://codepoints.net/search?DI=1 (Default_Ignorable_Code_Point)
      # \u2800 = https://codepoints.net/U+2800 (BRAILLE PATTERN BLANK)
      INVISIBLE_REGEX = /\A[[:space:]\p{di}\u2800]*\z/

      # Returns true if the string consists entirely of invisible characters. Like `#blank?`, but includes control
      # characters and certain other invisible Unicode characters that aren't classified as spaces.
      def invisible?
        match?(INVISIBLE_REGEX)
      end

      def to_escaped_for_sql_like
        string = self.gsub(/%|_|\*|\\\*|\\\\|\\/) do |str|
          case str
          when '%'    then '\%'
          when '_'    then '\_'
          when '*'    then '%'
          when '\*'   then '*'
          when '\\\\' then '\\\\'
          when '\\'   then '\\\\'
          end
        end

        string
      end

      # escape \ and * characters so that they're treated literally in LIKE searches.
      def escape_wildcards
        gsub(/\\/, '\\\\').gsub(/\*/, '\*')
      end

      def to_escaped_for_tsquery_split
        scan(/\S+/).map {|x| x.to_escaped_for_tsquery}.join(" & ")
      end

      def to_escaped_for_tsquery
        "'#{gsub(/\0/, '').gsub(/'/, '\0\0').gsub(/\\/, '\0\0\0\0')}'"
      end

      def truthy?
        self.match?(/\A(true|t|yes|y|on|1)\z/i)
      end

      def falsy?
        self.match?(/\A(false|f|no|n|off|0)\z/i)
      end

      def ilike?(pattern)
        pattern = Regexp.escape(pattern).gsub(/\\\*/, ".*")
        match?(/\A#{pattern}\z/i)
      end

      def normalize_whitespace
        # Normalize various horizontal space characters to ASCII space.
        text = gsub(/\p{Zs}|\t/, " ")

        # Strip various zero width space characters. Zero width joiner (200D)
        # is allowed because it's used in emoji.
        text = text.gsub(/[\u180E\u200B\u200C\u2060\uFEFF]/, "")

        # Normalize various line ending characters to CRLF.
        text = text.gsub(/\r?\n|\r|\v|\f|\u0085|\u2028|\u2029/, "\r\n")

        text
      end

      # Capitalize every word in the string. Like `titleize`, but doesn't remove underscores, apply inflection rules, or strip the `_id` suffix.
      #
      # @return [String] The string with every word capitalized.
      def startcase
        self.gsub(/(?<![a-z'])([a-z]+)/i, &:capitalize)
      end

      # @return [Boolean] True if the string contains only balanced parentheses; false if the string contains unbalanced parentheses.
      def has_balanced_parens?(open = "(", close = ")")
        parens = 0

        chars.each do |char|
          if char == open
            parens += 1
          elsif char == close
            parens -= 1
            return false if parens < 0
          end
        end

        parens == 0
      end
    end
  end
end

class String
  include Danbooru::Extensions::String
end

module Enumerable
  include Danbooru::Enumerable
end

module MimeNegotationExtension
  # Ignore all file extensions except for .html, .js, .json, and .xml when
  # parsing the file extension from the URL. Needed for wiki pages (e.g.
  # /wiki_pages/rnd.jpg).
  private def format_from_path_extension
    mime = super

    if mime&.symbol.in?(%i[html js json xml])
      mime
    else
      nil
    end
  end
end

ActionDispatch::Http::MimeNegotiation.prepend(MimeNegotationExtension)

# Make Symbol#to_s return a frozen string. This reduces allocations, but may be
# incompatible with some libraries.
#
# https://bugs.ruby-lang.org/issues/16150
# https://github.com/Shopify/symbol-fstring
Symbol.alias_method(:to_s, :name)
