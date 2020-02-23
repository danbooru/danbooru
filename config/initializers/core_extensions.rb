module Danbooru
  module Extensions
    module String
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
    end
  end
end

class String
  include Danbooru::Extensions::String
end

class FalseClass
  def to_i
    0
  end
end
