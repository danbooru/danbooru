module Iqdb
  module Responses
    class Response_201 < Base
      attr_reader :dbid, :imgid, :score, :width, :height

      def initialize(response_string)
        @dbid, @imgid, @score, @width, @height = response_string.split(/ /)
        @dbid = dbid.to_i
        @score = score.to_f
        @width = width.to_i
        @height = height.to_i
      end

      def post_id
        imgid.to_i(16)
      end
    end
  end
end
