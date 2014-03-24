module Iqdb
  module Responses
    class Response_200 < Base
      attr_reader :imgid, :score, :width, :height

      def initialize(response_string)
        @imgid, @score, @width, @height = response_string.split(/ /)
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
